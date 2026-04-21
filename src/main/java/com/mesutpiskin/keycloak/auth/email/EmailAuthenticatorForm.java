package com.mesutpiskin.keycloak.auth.email;

import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.AuthenticationFlowError;
import org.keycloak.authentication.AuthenticationFlowException;
import org.keycloak.authentication.CredentialValidator;
import org.keycloak.authentication.RequiredActionFactory;
import org.keycloak.authentication.RequiredActionProvider;
import org.keycloak.email.EmailException;
import org.keycloak.events.Errors;
import org.keycloak.forms.login.LoginFormsProvider;
import org.keycloak.models.AuthenticatorConfigModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.models.utils.FormMessage;
import org.keycloak.services.messages.Messages;
import org.keycloak.sessions.AuthenticationSessionModel;
import org.keycloak.authentication.authenticators.browser.AbstractUsernameFormAuthenticator;
import org.keycloak.common.util.SecretGenerator;
import org.keycloak.credential.CredentialProvider;

import org.jboss.logging.Logger;
import jakarta.ws.rs.core.MultivaluedMap;
import jakarta.ws.rs.core.Response;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Keycloak authenticator that implements two-factor authentication via email or
 * SMS.
 * <p>
 * This authenticator generates a one-time password (OTP) and sends it to the
 * user's registered email address or phone number. The user can choose their
 * preferred delivery method when SMS is enabled.
 * </p>
 * <p>
 * Features include:
 * <ul>
 * <li>Configurable code length and TTL (time-to-live)</li>
 * <li>Resend cooldown to prevent spam</li>
 * <li>Simulation mode for testing without sending actual emails</li>
 * <li>Brute force protection support</li>
 * <li>Code expiration handling</li>
 * <li>SMS delivery via configurable HTTP gateway</li>
 * <li>Method selection (email or SMS) when SMS is enabled</li>
 * </ul>
 * </p>
 *
 * @author Mesut Pişkin
 * @version 26.1.1
 * @since 1.0.0
 */
public class EmailAuthenticatorForm extends AbstractUsernameFormAuthenticator
        implements CredentialValidator<EmailAuthenticatorCredentialProvider> {

    protected static final Logger logger = Logger.getLogger(EmailAuthenticatorForm.class);
    private static final String CODE_ATTEMPTS = "emailCodeAttempts";

    /**
     * Initiates the authentication process by presenting either the method
     * selection
     * screen (if SMS is enabled) or directly sending the email code.
     *
     * @param context the authentication flow context containing user, session, and
     *                realm information
     */
    @Override
    public void authenticate(AuthenticationFlowContext context) {
        AuthenticatorConfigModel config = context.getAuthenticatorConfig();
        Map<String, String> configValues = config != null && config.getConfig() != null
                ? config.getConfig()
                : Map.of();

        boolean smsEnabled = Boolean.parseBoolean(
                configValues.getOrDefault(EmailConstants.SMS_ENABLED,
                        String.valueOf(EmailConstants.DEFAULT_SMS_ENABLED)));

        String phoneAttribute = configValues.getOrDefault(
                EmailConstants.SMS_PHONE_ATTRIBUTE,
                EmailConstants.DEFAULT_SMS_PHONE_ATTRIBUTE);

        UserModel user = context.getUser();
        String userPhone = getUserPhone(user, phoneAttribute);
        boolean userHasPhone = userPhone != null && !userPhone.trim().isEmpty();

        if (smsEnabled && userHasPhone) {
            // Show method selection screen
            LoginFormsProvider form = context.form().setExecution(context.getExecution().getId());
            form.setAttribute("attemptedUserEmail", user.getEmail());
            form.setAttribute("smsEnabled", true);
            form.setAttribute("userHasPhone", true);
            form.setAttribute("showMethodSelection", true);
            // Mask phone for display
            form.setAttribute("maskedPhone", maskPhone(userPhone));
            form.setAttribute("maskedEmail", maskEmail(user.getEmail()));
            context.challenge(form.createForm("email-code-form.ftl"));
        } else {
            // SMS not available, go directly to email flow (backward compatible)
            context.challenge(challenge(context, null));
        }
    }

    /**
     * Creates the authentication challenge response with the email code entry form.
     * <p>
     * Generates and sends the email code if not already sent, prepares the form
     * with any error messages, and returns the rendered form response.
     * </p>
     *
     * @param context the authentication flow context
     * @param error   optional error message key to display
     * @param field   optional field name associated with the error
     * @return the HTTP response containing the rendered form
     */
    @Override
    protected Response challenge(AuthenticationFlowContext context, String error, String field) {
        AuthenticationSessionModel session = context.getAuthenticationSession();
        String deliveryMethod = session.getAuthNote(EmailConstants.DELIVERY_METHOD);

        if (deliveryMethod == null) {
            deliveryMethod = EmailConstants.METHOD_EMAIL;
        }

        generateAndSendCode(context, deliveryMethod);
        LoginFormsProvider form = prepareForm(context, null);
        form.setAttribute("attemptedUserEmail", context.getUser().getEmail());
        form.setAttribute("deliveryMethod", deliveryMethod);
        applyFormMessage(form, error, field);
        return form.createForm("email-code-form.ftl");
    }

    /**
     * Generates a random code and sends it via the specified delivery method.
     *
     * @param context        the authentication flow context
     * @param deliveryMethod "email" or "sms"
     */
    private void generateAndSendCode(AuthenticationFlowContext context, String deliveryMethod) {
        AuthenticatorConfigModel config = context.getAuthenticatorConfig();
        AuthenticationSessionModel session = context.getAuthenticationSession();

        if (session.getAuthNote(EmailConstants.CODE) != null) {
            // skip sending code
            return;
        }

        Map<String, String> configValues = config != null && config.getConfig() != null
                ? config.getConfig()
                : Map.of();

        int length = resolvePositiveInt(configValues, EmailConstants.CODE_LENGTH, EmailConstants.DEFAULT_LENGTH);
        int ttl = resolvePositiveInt(configValues, EmailConstants.CODE_TTL, EmailConstants.DEFAULT_TTL);
        int resendCooldown = resolvePositiveInt(configValues, EmailConstants.RESEND_COOLDOWN,
                EmailConstants.DEFAULT_RESEND_COOLDOWN);

        String code = SecretGenerator.getInstance().randomString(length, SecretGenerator.DIGITS);
        if (config != null && Boolean.parseBoolean(config.getConfig().get(EmailConstants.SIMULATION_MODE))) {
            logger.infof("***** SIMULATION MODE ***** Code for user %s is: %s (method: %s)",
                    context.getUser().getUsername(), code, deliveryMethod);
        } else if (EmailConstants.METHOD_SMS.equals(deliveryMethod)) {
            sendSmsWithCode(context, code, ttl);
        } else {
            sendEmailWithCode(context, code, ttl);
        }
        session.setAuthNote(EmailConstants.CODE, code);
        long now = System.currentTimeMillis();
        session.setAuthNote(EmailConstants.CODE_TTL, Long.toString(now + (ttl * 1000L)));
        session.setAuthNote(EmailConstants.CODE_RESEND_AVAILABLE_AFTER, Long.toString(now + (resendCooldown * 1000L)));
    }

    /**
     * Resolves a positive integer configuration value with validation and fallback.
     *
     * @param configValues the configuration map
     * @param key          the configuration key to resolve
     * @param defaultValue the fallback value if parsing fails or value is invalid
     * @return the parsed positive integer or the default value
     */
    private int resolvePositiveInt(Map<String, String> configValues, String key, int defaultValue) {
        String raw = configValues.get(key);
        if (raw == null || raw.isBlank()) {
            return defaultValue;
        }
        try {
            int parsed = Integer.parseInt(raw.trim());
            if (parsed <= 0) {
                logger.warnf("Configuration value for %s was non-positive ('%s'); falling back to default %d", key, raw,
                        defaultValue);
                return defaultValue;
            }
            return parsed;
        } catch (NumberFormatException ex) {
            logger.warnf("Configuration value for %s was invalid ('%s'); falling back to default %d", key, raw,
                    defaultValue);
            return defaultValue;
        }
    }

    /**
     * Processes the form submission when the user enters the email code.
     * <p>
     * Validates the submitted code against the stored code, checking for expiration
     * and correctness. Handles special form actions like "resend", "cancel", and
     * "selectMethod".
     * On successful validation, marks the authentication as successful.
     * </p>
     *
     * @param context the authentication flow context
     */
    @Override
    public void action(AuthenticationFlowContext context) {
        UserModel userModel = context.getUser();
        if (!enabledUser(context, userModel)) {
            // error in context is set in enabledUser/isDisabledByBruteForce
            return;
        }

        MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();

        // Handle method selection
        if (formData.containsKey("selectMethod")) {
            String selectedMethod = formData.getFirst("deliveryMethod");
            if (selectedMethod == null || selectedMethod.isBlank()) {
                selectedMethod = EmailConstants.METHOD_EMAIL;
            }
            // Validate the method
            if (!EmailConstants.METHOD_EMAIL.equals(selectedMethod)
                    && !EmailConstants.METHOD_SMS.equals(selectedMethod)) {
                selectedMethod = EmailConstants.METHOD_EMAIL;
            }

            AuthenticationSessionModel session = context.getAuthenticationSession();
            session.setAuthNote(EmailConstants.DELIVERY_METHOD, selectedMethod);

            // Now generate and send code via chosen method
            context.challenge(challenge(context, null));
            return;
        }

        if (handleFormShortcuts(context, formData)) {
            return;
        }

        if (isValidCodeContext(context, userModel, formData)) {
            resetEmailCode(context);
            context.success();
        }
    }

    private boolean handleFormShortcuts(AuthenticationFlowContext context, MultivaluedMap<String, String> formData) {
        if (formData.containsKey("resend")) {
            AuthenticationSessionModel session = context.getAuthenticationSession();
            Long remainingSeconds = getRemainingSeconds(session);
            if (remainingSeconds != null && remainingSeconds > 0L) {
                LoginFormsProvider form = prepareForm(context, remainingSeconds);
                String deliveryMethod = session.getAuthNote(EmailConstants.DELIVERY_METHOD);
                form.setAttribute("deliveryMethod",
                        deliveryMethod != null ? deliveryMethod : EmailConstants.METHOD_EMAIL);
                applyFormMessage(form, "email-authenticator-resend-cooldown", null, remainingSeconds);
                context.challenge(form.createForm("email-code-form.ftl"));
                return true;
            }

            resetEmailCode(context);
            context.challenge(challenge(context, null));
            return true;
        }

        if (formData.containsKey("cancel")) {
            resetEmailCode(context);
            context.resetFlow();
            return true;
        }

        return false;
    }

    private record CodeContext(String storedCode, Long expiresAt, String submittedCode) {
    }

    private CodeContext buildCodeContext(AuthenticationSessionModel session, MultivaluedMap<String, String> formData) {
        String storedCode = session.getAuthNote(EmailConstants.CODE);
        String ttlNote = session.getAuthNote(EmailConstants.CODE_TTL);
        Long expiresAt = null;
        if (ttlNote != null) {
            try {
                expiresAt = Long.parseLong(ttlNote);
            } catch (NumberFormatException ex) {
                logger.warnf("Invalid TTL value '%s' found for email authenticator; treating as expired", ttlNote);
            }
        }

        String submittedRaw = formData.getFirst(EmailConstants.CODE);
        String submittedCode = submittedRaw == null ? null : submittedRaw.strip();

        return new CodeContext(storedCode, expiresAt, submittedCode);
    }

    private boolean isValidCodeContext(AuthenticationFlowContext context, UserModel user,
            MultivaluedMap<String, String> formData) {
        CodeContext codeContext = buildCodeContext(context.getAuthenticationSession(), formData);
        if (codeContext.storedCode() == null || codeContext.expiresAt() == null) {
            context.getEvent().user(user).error(Errors.INVALID_USER_CREDENTIALS);
            Response challengeResponse = challenge(context, Messages.INVALID_ACCESS_CODE, EmailConstants.CODE);
            context.failureChallenge(AuthenticationFlowError.INVALID_CREDENTIALS, challengeResponse);
            return false;
        }

        if (codeContext.submittedCode() == null || codeContext.submittedCode().isEmpty()) {
            context.challenge(challenge(context, Messages.MISSING_TOTP, EmailConstants.CODE));
            return false;
        }

        if (codeContext.expiresAt() < System.currentTimeMillis()) {
            context.getEvent().user(user).error(Errors.EXPIRED_CODE);
            Response challengeResponse = challenge(context, "email-authenticator-code-expired",
                    EmailConstants.CODE);
            context.failureChallenge(AuthenticationFlowError.EXPIRED_CODE, challengeResponse);
            return false;
        }

        if (codeContext.submittedCode().equals(codeContext.storedCode()))
            return true;

        context.getEvent().user(user).error(Errors.INVALID_USER_CREDENTIALS);

        AuthenticationSessionModel session = context.getAuthenticationSession();
        int attempts = incrementAttempts(session);

        AuthenticatorConfigModel config = context.getAuthenticatorConfig();
        Map<String, String> configValues = config != null && config.getConfig() != null
                ? config.getConfig()
                : Map.of();
        int maxAttempts = resolvePositiveInt(configValues, EmailConstants.MAX_ATTEMPTS,
                EmailConstants.DEFAULT_MAX_ATTEMPTS);

        if (attempts >= maxAttempts) {
            resetEmailCode(context);
            LoginFormsProvider form = prepareForm(context, null);
            form.setAttribute("maxAttemptsReached", true);
            applyFormMessage(form, "email-authenticator-too-many-attempts", EmailConstants.CODE);
            Response challengeResponse = form.createForm("email-code-form.ftl");
            context.failureChallenge(AuthenticationFlowError.INVALID_CREDENTIALS, challengeResponse);
        } else {
            Response challengeResponse = challenge(context, Messages.INVALID_ACCESS_CODE, EmailConstants.CODE);
            context.failureChallenge(AuthenticationFlowError.INVALID_CREDENTIALS, challengeResponse);
        }
        return false;
    }

    private LoginFormsProvider prepareForm(AuthenticationFlowContext context, Long remainingSeconds) {
        AuthenticationSessionModel session = context.getAuthenticationSession();
        LoginFormsProvider form = context.form().setExecution(context.getExecution().getId());
        Long secondsToExpose = remainingSeconds != null ? remainingSeconds : getRemainingSeconds(session);
        if (secondsToExpose != null && secondsToExpose > 0L)
            form.setAttribute("resendAvailableInSeconds", secondsToExpose);

        return form;
    }

    private Long getRemainingSeconds(AuthenticationSessionModel session) {
        String rawResendAfter = session.getAuthNote(EmailConstants.CODE_RESEND_AVAILABLE_AFTER);
        if (rawResendAfter == null) {
            return null;
        }
        Long resendAt = null;
        try {
            resendAt = Long.parseLong(rawResendAfter);
        } catch (NumberFormatException ex) {
            logger.warnf("Invalid resend availability timestamp '%s' for email authenticator; allowing resend",
                    rawResendAfter);
            session.removeAuthNote(EmailConstants.CODE_RESEND_AVAILABLE_AFTER);
            return null;
        }
        long remainingMillis = resendAt - System.currentTimeMillis();
        return Math.max(0L, (remainingMillis + EmailConstants.MILLIS_ROUNDING_OFFSET) / 1000L);
    }

    private void applyFormMessage(LoginFormsProvider form, String messageKey, String field, Object... messageParams) {
        if (messageKey == null) {
            return;
        }
        if (field != null) {
            form.addError(new FormMessage(field, messageKey, messageParams));
        } else {
            form.setError(messageKey, messageParams);
        }
    }

    protected String disabledByBruteForceError() {
        return Messages.INVALID_ACCESS_CODE;
    }

    private void resetEmailCode(AuthenticationFlowContext context) {
        AuthenticationSessionModel session = context.getAuthenticationSession();
        session.removeAuthNote(EmailConstants.CODE);
        session.removeAuthNote(EmailConstants.CODE_TTL);
        session.removeAuthNote(EmailConstants.CODE_RESEND_AVAILABLE_AFTER);
        session.removeAuthNote(CODE_ATTEMPTS);
        session.removeAuthNote(EmailConstants.DELIVERY_METHOD);
    }

    private int incrementAttempts(AuthenticationSessionModel session) {
        String raw = session.getAuthNote(CODE_ATTEMPTS);
        int attempts = 1;
        if (raw != null) {
            try {
                attempts = Integer.parseInt(raw) + 1;
            } catch (NumberFormatException ignored) {
                // corrupt value, start over
            }
        }
        session.setAuthNote(CODE_ATTEMPTS, Integer.toString(attempts));
        return attempts;
    }

    @Override
    public boolean requiresUser() {
        return true;
    }

    @Override
    public boolean configuredFor(KeycloakSession session, RealmModel realm, UserModel user) {
        // Always return true as long as the user has an email address in their profile.
        // This tells Keycloak "Yes, they are already set up!" and completely bypasses
        // the Enable screen.
        return user.getEmail() != null && !user.getEmail().trim().isEmpty();
    }

    @Override
    public EmailAuthenticatorCredentialProvider getCredentialProvider(KeycloakSession session) {
        return (EmailAuthenticatorCredentialProvider) session.getProvider(CredentialProvider.class,
                EmailAuthenticatorCredentialProviderFactory.PROVIDER_ID);
    }

    @Override
    public void setRequiredActions(KeycloakSession session, RealmModel realm, UserModel user) {
        // user.addRequiredAction(EmailAuthenticatorRequiredAction.PROVIDER_ID);
    }

    @Override
    public List<RequiredActionFactory> getRequiredActions(KeycloakSession session) {
        return Collections.singletonList((EmailAuthenticatorRequiredActionFactory) session.getKeycloakSessionFactory()
                .getProviderFactory(RequiredActionProvider.class, EmailAuthenticatorRequiredAction.PROVIDER_ID));
    }

    @Override
    public void close() {
        // NOOP
    }

    /**
     * Gets the user's phone number from a configurable user attribute.
     *
     * @param user           the user model
     * @param phoneAttribute the attribute name storing the phone number
     * @return the phone number or null if not set
     */
    private String getUserPhone(UserModel user, String phoneAttribute) {
        List<String> phones = user.getAttributes().get(phoneAttribute);
        if (phones != null && !phones.isEmpty()) {
            return phones.get(0);
        }
        return null;
    }

    /**
     * Masks a phone number for display, showing only last 4 digits.
     * Example: +66812345678 → ****5678
     */
    private String maskPhone(String phone) {
        if (phone == null || phone.length() <= 4)
            return phone;
        return "****" + phone.substring(phone.length() - 4);
    }

    /**
     * Masks an email for display.
     * Example: user@example.com → u***@example.com
     */
    private String maskEmail(String email) {
        if (email == null)
            return null;
        int atPos = email.indexOf('@');
        if (atPos <= 1)
            return email;
        return email.charAt(0) + "***" + email.substring(atPos);
    }

    /**
     * Sends an OTP code via SMS using the configured HTTP SMS gateway.
     *
     * @param context the authentication flow context
     * @param code    the OTP code to send
     * @param ttl     the code TTL in seconds
     */
    private void sendSmsWithCode(AuthenticationFlowContext context, String code, int ttl) {
        AuthenticatorConfigModel config = context.getAuthenticatorConfig();
        Map<String, String> configValues = config != null && config.getConfig() != null
                ? config.getConfig()
                : Map.of();

        String apiUrl = configValues.get(EmailConstants.SMS_API_URL);
        String apiKey = configValues.get(EmailConstants.SMS_API_KEY);
        String apiSecret = configValues.get(EmailConstants.SMS_API_SECRET);
        String senderId = configValues.get(EmailConstants.SMS_SENDER_ID);
        String phoneAttribute = configValues.getOrDefault(
                EmailConstants.SMS_PHONE_ATTRIBUTE,
                EmailConstants.DEFAULT_SMS_PHONE_ATTRIBUTE);

        UserModel user = context.getUser();
        String phoneNumber = getUserPhone(user, phoneAttribute);

        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            logger.warnf("Could not send SMS: no phone number for user %s", user.getUsername());
            throw new AuthenticationFlowException(AuthenticationFlowError.INVALID_USER);
        }

        if (apiUrl == null || apiUrl.trim().isEmpty()) {
            logger.errorf("SMS API URL is not configured");
            throw new AuthenticationFlowException(AuthenticationFlowError.INTERNAL_ERROR);
        }

        RealmModel realm = context.getRealm();
        String realmName = realm.getDisplayName() != null ? realm.getDisplayName() : realm.getName();

        // Clean phone number: ThaiBulkSMS often prefers numbers without '+' (e.g.,
        // 66812345678)
        String cleanPhone = phoneNumber.startsWith("+") ? phoneNumber.substring(1) : phoneNumber;

        // Build Form Data payload (x-www-form-urlencoded) for ThaiBulkSMS
        String messageText = realmName + " access code: " + code + ". Valid for " + ttl + " seconds.";
        String urlParameters = String.format(
                "msisdn=%s&message=%s&sender=%s&force=standard",
                java.net.URLEncoder.encode(cleanPhone, StandardCharsets.UTF_8),
                java.net.URLEncoder.encode(messageText, StandardCharsets.UTF_8),
                java.net.URLEncoder.encode(senderId != null ? senderId : "", StandardCharsets.UTF_8));

        try {
            URL url = new URL(apiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setRequestProperty("Accept", "application/json");

            // Handle Authentication
            if (apiKey != null && !apiKey.trim().isEmpty()) {
                if (apiSecret != null && !apiSecret.trim().isEmpty()) {
                    String auth = apiKey + ":" + apiSecret;
                    String encodedAuth = java.util.Base64.getEncoder().encodeToString(auth.getBytes());
                    conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
                } else if (apiKey.contains(":")) {
                    String encodedAuth = java.util.Base64.getEncoder().encodeToString(apiKey.getBytes());
                    conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
                } else {
                    conn.setRequestProperty("Authorization", "Bearer " + apiKey);
                }
            }

            conn.setDoOutput(true);
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = urlParameters.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int responseCode = conn.getResponseCode();
            if (responseCode >= 200 && responseCode < 300) {
                logger.infof("SMS sent successfully to %s for user %s", cleanPhone, user.getUsername());
            } else {
                // Read error message from the response body to help debugging
                String errorResponse = "";
                try (java.util.Scanner s = new java.util.Scanner(conn.getErrorStream(), StandardCharsets.UTF_8)
                        .useDelimiter("\\A")) {
                    errorResponse = s.hasNext() ? s.next() : "";
                } catch (Exception ignored) {
                }

                logger.errorf("SMS API returned error code %d for user %s. Response: %s",
                        responseCode, user.getUsername(), errorResponse);
            }
            conn.disconnect();
        } catch (Exception e) {
            logger.errorf(e, "Failed to send SMS to %s for user %s", phoneNumber, user.getUsername());
        }
    }

    private void sendEmailWithCode(AuthenticationFlowContext context, String code, int ttl) {
        KeycloakSession session = context.getSession();
        RealmModel realm = context.getRealm();
        UserModel user = context.getUser();

        if (user.getEmail() == null) {
            logger.warnf("Could not send access code email due to missing email. realm=%s user=%s", realm.getId(),
                    user.getUsername());
            throw new AuthenticationFlowException(AuthenticationFlowError.INVALID_USER);
        }

        // Build email message with template data
        Map<String, Object> templateData = new HashMap<>();
        templateData.put("username", user.getUsername());
        templateData.put("code", code);
        templateData.put("ttl", ttl);

        String realmName = realm.getDisplayName() != null ? realm.getDisplayName() : realm.getName();
        String subject = realmName + " access code";

        com.mesutpiskin.keycloak.auth.email.model.EmailMessage message = com.mesutpiskin.keycloak.auth.email.model.EmailMessage
                .builder()
                .to(user.getEmail())
                .subject(subject)
                .templateData(templateData)
                .build();

        // Determine email provider from config
        AuthenticatorConfigModel config = context.getAuthenticatorConfig();
        Map<String, String> configMap = config != null && config.getConfig() != null
                ? config.getConfig()
                : Map.of();

        String providerTypeStr = configMap.getOrDefault(
                EmailConstants.EMAIL_PROVIDER_TYPE,
                EmailConstants.DEFAULT_EMAIL_PROVIDER);
        com.mesutpiskin.keycloak.auth.email.model.EmailProviderType providerType = com.mesutpiskin.keycloak.auth.email.model.EmailProviderType
                .fromString(providerTypeStr);

        try {
            // Create email sender based on configuration
            com.mesutpiskin.keycloak.auth.email.service.EmailSender emailSender = com.mesutpiskin.keycloak.auth.email.service.EmailSenderFactory
                    .createEmailSender(
                            providerType,
                            configMap,
                            session,
                            realm,
                            user);

            // Send email
            emailSender.sendEmail(message);
            logger.infof("Email sent successfully via %s to %s",
                    emailSender.getProviderName(), user.getEmail());

        } catch (EmailException e) {
            // Fallback to Keycloak SMTP if enabled
            boolean fallbackEnabled = com.mesutpiskin.keycloak.auth.email.service.EmailSenderFactory
                    .isFallbackEnabled(configMap);

            if (fallbackEnabled
                    && providerType != com.mesutpiskin.keycloak.auth.email.model.EmailProviderType.KEYCLOAK) {
                logger.warnf(e, "Primary email provider (%s) failed, falling back to Keycloak SMTP",
                        providerType.getDisplayName());
                try {
                    com.mesutpiskin.keycloak.auth.email.service.EmailSender fallbackSender = new com.mesutpiskin.keycloak.auth.email.service.impl.KeycloakEmailSender(
                            session, realm, user);
                    fallbackSender.sendEmail(message);
                    logger.infof("Email sent successfully via fallback Keycloak SMTP to %s", user.getEmail());
                } catch (EmailException fallbackEx) {
                    logger.errorf(fallbackEx, "Fallback email provider also failed. realm=%s user=%s",
                            realm.getId(), user.getUsername());
                }
            } else {
                logger.errorf(e, "Failed to send access code email. realm=%s user=%s",
                        realm.getId(), user.getUsername());
            }
        }
    }
}
