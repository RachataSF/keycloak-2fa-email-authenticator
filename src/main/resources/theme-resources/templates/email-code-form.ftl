<#import "template.ftl" as layout>
    <@layout.registrationLayout displayMessage=!messagesPerField.existsError('emailCode'); section>
        <#if section="header">
            ${msg("doLogIn")}
            <#elseif section="form">
                <#assign hasError=messagesPerField.existsError('emailCode') || (maxAttemptsReached?? &&
                    maxAttemptsReached)>
                    <#assign showMethodSelection=(showMethodSelection?? && showMethodSelection!false)>
                        <#assign smsAvailable=(smsEnabled?? && smsEnabled!false && userHasPhone?? &&
                            userHasPhone!false)>
                            <#assign currentMethod=deliveryMethod!'email'>

                                <style>
                                    /* Custom Corporate Styling */
                                    html,
                                    body {
                                        background-image: none !important;
                                        background-attachment: unset !important;
                                    }

                                    body {
                                        background: linear-gradient(135deg, #075985 0%, #0ea5e9 100%) !important;
                                        display: flex !important;
                                        flex-direction: column !important;
                                        justify-content: center !important;
                                        align-items: center !important;
                                        min-height: 100vh !important;
                                        margin: 0;
                                    }

                                    body {
                                        color: #757575 !important;
                                    }

                                    .pf-c-form__label,
                                    .kcLabelClass,
                                    label {
                                        color: #5e5d5d !important;
                                        padding-left: 15px !important;
                                        display: block;
                                        text-align: center;
                                        font-size: 1rem !important;
                                        font-weight: bold;
                                        margin-bottom: 20px;
                                        /* text-lg */
                                    }

                                    .pf-c-button,
                                    input[type="submit"].btn-primary,
                                    .btn-primary,
                                    .kcButtonClass {
                                        background-color: #0ea5e9 !important;
                                        border-color: #0ea5e9 !important;
                                        color: #ffffff !important;
                                        border-radius: 0.75rem !important;
                                        /* rounded-xl */
                                        padding: 0.5rem 1rem !important;
                                        /* py-2 px-4 */
                                        width: auto !important;
                                        /* NOT w-full */
                                        box-sizing: border-box !important;
                                        font-size: 1rem !important;
                                        /* text-lg */
                                    }

                                    .pf-c-button.pf-m-primary:hover,
                                    input[type="submit"].btn-primary:hover,
                                    .btn-primary:hover,
                                    a.kcButtonClass:hover {
                                        background-color: #075985 !important;
                                        border-color: #075985 !important;
                                        color: #ffffff !important;
                                    }

                                    input[name="resend"],
                                    input[name="cancel"] {
                                        background-color: #7dd3fc !important;
                                        border-color: #7dd3fc !important;
                                        color: #0ea5e9 !important;
                                    }

                                    input[name="resend"]:hover,
                                    input[name="cancel"]:hover {
                                        background-color: #0ea5e9 !important;
                                        border-color: #0ea5e9 !important;
                                        color: #ffffff !important;
                                    }

                                    a,
                                    .kc-link {
                                        color: #0ea5e9 !important;
                                    }

                                    a:hover,
                                    .kc-link:hover {
                                        color: #075985 !important;
                                    }

                                    .pf-c-form-control,
                                    input[type="text"],
                                    input[type="password"] {
                                        background: rgba(255, 255, 255, 0.5) !important;
                                        border-color: #757575 !important;
                                        color: #757575 !important;
                                        border-radius: 0.75rem !important;
                                        /* rounded-xl */
                                        width: 100% !important;
                                        /* w-full */
                                        box-sizing: border-box !important;
                                        padding: 10px 15px !important;
                                    }

                                    .pf-c-form-control:focus,
                                    input[type="text"]:focus,
                                    input[type="password"]:focus {
                                        border-color: #0ea5e9 !important;
                                        box-shadow: 0 0 0 1px #0ea5e9 !important;
                                        outline: none !important;
                                    }

                                    /* Error state: red border on invalid inputs */
                                    input[aria-invalid="true"],
                                    .pf-c-form-control[aria-invalid="true"] {
                                        border-color: #e53935 !important;
                                        box-shadow: 0 0 0 1px #e53935 !important;
                                    }

                                    /* Error message text */
                                    #input-error,
                                    #input-error-otp-code,
                                    .pf-c-form__helper-text--error,
                                    .kcInputErrorMessageClass,
                                    .alert-error,
                                    .kc-feedback-text {
                                        color: #e53935 !important;
                                        font-size: 0.85rem !important;
                                        font-weight: 600 !important;
                                        margin-top: 4px !important;
                                        display: block !important;
                                    }

                                    /* Layout & Sizing Fixes */
                                    .login-pf-page .card-pf,
                                    .kc-form-card {
                                        width: 60vh !important;
                                        max-width: 90vw !important;
                                        margin: 0 auto !important;
                                        border-radius: 3rem !important;
                                        padding: 3rem !important;
                                        background-color: rgba(255, 255, 255, 0.8) !important;
                                        border: 7px solid #9adafd !important;
                                        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1) !important;
                                    }

                                    #kc-form {
                                        width: 100% !important;
                                    }

                                    /* Realm Name (New iFims) at the very top */
                                    #kc-header-wrapper {
                                        font-size: 38px !important;
                                        font-weight: 800 !important;
                                        color: #ffffff !important;
                                        text-transform: uppercase;
                                        letter-spacing: 1px;
                                        text-align: center;
                                        margin-bottom: 0.25rem !important;
                                        /* gap-1 equivalent */
                                    }

                                    /* Sign in to your account */
                                    #kc-header h1,
                                    #kc-page-title {
                                        font-size: 26px !important;
                                        font-weight: 400 !important;
                                        /* NOT BOLD */
                                        color: #757575 !important;
                                        text-align: center;
                                        margin-bottom: 20px;
                                    }

                                    #kc-form-buttons,
                                    .pf-c-form__actions {
                                        margin-top: 20px !important;
                                        display: flex !important;
                                        justify-content: center !important;
                                        gap: 25px;
                                        width: 100%;
                                    }

                                    .pf-c-form__actions>* {
                                        flex-shrink: 1;
                                    }

                                    /* Resend button disabled/cooldown state */
                                    #kc-resend-btn:disabled,
                                    #kc-resend-btn[disabled] {
                                        background-color: #d0d0d0 !important;
                                        border-color: #d0d0d0 !important;
                                        color: #888888 !important;
                                        cursor: not-allowed !important;
                                        opacity: 0.7 !important;
                                    }

                                    /* Username & Restart Login — hidden */
                                    #kc-username {
                                        display: none !important;
                                    }

                                    /* SVG Envelope matches primary color */
                                    svg#ee13b174-13f0-43ea-b921-f168b1054f8d {
                                        fill: #0ea5e9 !important;
                                        stroke: #0ea5e9 !important;
                                    }

                                    /* ===== Method Selection Styling ===== */
                                    .method-selection-container {
                                        text-align: center;
                                        padding: 20px 0;
                                    }

                                    .method-selection-title {
                                        font-size: 1.2em;
                                        color: #555;
                                        font-weight: bold;
                                        margin-bottom: 25px;
                                    }

                                    .method-buttons {
                                        display: flex;
                                        justify-content: center;
                                        gap: 20px;
                                        flex-wrap: wrap;
                                    }

                                    .method-btn {
                                        display: flex;
                                        flex-direction: column;
                                        align-items: center;
                                        justify-content: center;
                                        width: 140px;
                                        height: 130px;
                                        border: 3px solid #bae6fd;
                                        border-radius: 1.5rem;
                                        background: rgba(255, 255, 255, 0.7);
                                        cursor: pointer;
                                        transition: all 0.3s ease;
                                        text-decoration: none !important;
                                        padding: 15px;
                                    }

                                    .method-btn:hover {
                                        border-color: #0ea5e9;
                                        background: rgba(14, 165, 233, 0.08);
                                        transform: translateY(-3px);
                                        box-shadow: 0 6px 20px rgba(14, 165, 233, 0.2);
                                    }

                                    .method-btn:active {
                                        transform: translateY(0);
                                    }

                                    .method-btn .method-icon {
                                        width: 48px;
                                        height: 48px;
                                        margin-bottom: 8px;
                                        display: flex;
                                        align-items: center;
                                        justify-content: center;
                                    }

                                    .method-btn .method-icon svg {
                                        width: 100%;
                                        height: 100%;
                                        fill: #0ea5e9;
                                    }

                                    .method-btn:hover .method-icon svg {
                                        fill: #075985;
                                    }

                                    .method-btn .method-label {
                                        font-size: 1rem;
                                        font-weight: 600;
                                        color: #555;
                                    }

                                    .method-btn .method-info {
                                        font-size: 0.75rem;
                                        color: #999;
                                        margin-top: 3px;
                                    }

                                    .method-btn:hover .method-label {
                                        color: #0ea5e9;
                                    }

                                    /* SMS icon animation */
                                    @keyframes phoneBuzz {

                                        0%,
                                        100% {
                                            transform: rotate(0deg);
                                        }

                                        25% {
                                            transform: rotate(-5deg);
                                        }

                                        75% {
                                            transform: rotate(5deg);
                                        }
                                    }

                                    .sms-icon-anim {
                                        display: inline-block;
                                        width: 50px;
                                        height: 50px;
                                        margin-bottom: 10px;
                                        animation: phoneBuzz 0.5s infinite ease-in-out;
                                    }

                                    .sms-icon-anim svg {
                                        width: 100%;
                                        height: 100%;
                                        fill: #0ea5e9;
                                    }
                                </style>

                                <script>
                                    function handleMethodSelection(method) {
                                        // Set the value for the hidden input
                                        const input = document.getElementById('deliveryMethodInput');
                                        if (input) input.value = method;

                                        // Disable both buttons to prevent double-sending
                                        const buttons = document.querySelectorAll('.method-btn');
                                        setTimeout(function () {
                                            buttons.forEach(function (btn) {
                                                btn.disabled = true;
                                                btn.style.opacity = '0.6';
                                                btn.style.cursor = 'not-allowed';
                                            });
                                        }, 5);
                                    }
                                </script>

                                <!-- ===== Method Selection Container ===== -->
                                <div id="method-selection-container" class="${properties.kcFormGroupClass!}"
                                    style="display: <#if showMethodSelection>block<#else>none</#if>;">
                                    <div class="method-selection-container">
                                        <p class="method-selection-title">${msg("selectDeliveryMethod")}</p>
                                        <form id="kc-method-select-form" action="${url.loginAction}" method="post">
                                            <input type="hidden" name="deliveryMethod" id="deliveryMethodInput"
                                                value="email" />
                                            <input type="hidden" name="selectMethod" value="true" />
                                            <div class="method-buttons">
                                                <button type="submit" class="method-btn"
                                                    onclick="handleMethodSelection('email');">
                                                    <span class="method-icon">
                                                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                                            <path
                                                                d="M20 4H4C2.9 4 2.01 4.9 2.01 6L2 18C2 19.1 2.9 20 4 20H20C21.1 20 22 19.1 22 18V6C22 4.9 21.1 4.4 20 4ZM20 18H4V8L12 13L20 8V18ZM12 11L4 6H20L12 11Z" />
                                                        </svg>
                                                    </span>
                                                    <span class="method-label">${msg("sendViaEmail")}</span>
                                                    <#if maskedEmail??>
                                                        <span class="method-info">${maskedEmail}</span>
                                                    </#if>
                                                </button>
                                                <button type="submit" class="method-btn"
                                                    onclick="handleMethodSelection('sms');">
                                                    <span class="method-icon">
                                                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                                            <path
                                                                d="M17 1.01L7 1C5.9 1 5 1.9 5 3V21C5 22.1 5.9 23 7 23H17C18.1 23 19 22.1 19 21V3C19 1.9 18.1 1.01 17 1.01ZM17 19H7V5H17V19ZM16 7H8V9H16V7ZM16 11H8V13H16V11ZM16 15H8V17H16V15Z" />
                                                        </svg>
                                                    </span>
                                                    <span class="method-label">${msg("sendViaSms")}</span>
                                                    <#if maskedPhone??>
                                                        <span class="method-info">${maskedPhone}</span>
                                                    </#if>
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </div>

                                <!-- Loading Container (Shown while sending code) -->
                                <div id="loading-container" class="${properties.kcFormGroupClass!}"
                                    style="display: <#if !hasError && !showMethodSelection>block<#else>none</#if>; text-align: center; margin-bottom: 20px; padding: 20px 0;">
                                    <style>
                                        @keyframes flyEnvelope {
                                            0% {
                                                transform: translateX(-60px) translateY(10px) rotate(-10deg) scale(0.8);
                                                opacity: 0;
                                            }

                                            30% {
                                                transform: translateX(-10px) translateY(0px) rotate(0deg) scale(1.1);
                                                opacity: 1;
                                            }

                                            70% {
                                                transform: translateX(10px) translateY(0px) rotate(0deg) scale(1.1);
                                                opacity: 1;
                                            }

                                            100% {
                                                transform: translateX(60px) translateY(-10px) rotate(10deg) scale(0.8);
                                                opacity: 0;
                                            }
                                        }

                                        .envelope-icon {
                                            display: inline-block;
                                            width: 50px;
                                            height: 50px;
                                            margin-bottom: 10px;
                                            animation: flyEnvelope 2s infinite ease-in-out;
                                        }

                                        .envelope-icon svg {
                                            width: 100%;
                                            height: 100%;
                                            fill: #0ea5e9;
                                        }
                                    </style>

                                    <#if currentMethod=="sms">
                                        <div class="sms-icon-anim">
                                            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                                <path
                                                    d="M17 1.01L7 1C5.9 1 5 1.9 5 3V21C5 22.1 5.9 23 7 23H17C18.1 23 19 22.1 19 21V3C19 1.9 18.1 1.01 17 1.01ZM17 19H7V5H17V19ZM16 7H8V9H16V7ZM16 11H8V13H16V11ZM16 15H8V17H16V15Z" />
                                            </svg>
                                        </div>
                                        <p id="otp-sending-text"
                                            style="font-size: 1.2em; color: #555; font-weight: bold; margin-top: 10px;">
                                            ${msg("smsSendingText")}.</p>
                                        <#else>
                                            <div class="envelope-icon">
                                                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                                    <path
                                                        d="M20 4H4C2.9 4 2.01 4.9 2.01 6L2 18C2 19.1 2.9 20 4 20H20C21.1 20 22 19.1 22 18V6C22 4.9 21.1 4.4 20 4ZM20 18H4V8L12 13L20 8V18ZM12 11L4 6H20L12 11Z" />
                                                </svg>
                                            </div>
                                            <p id="otp-sending-text"
                                                style="font-size: 1.2em; color: #555; font-weight: bold; margin-top: 10px;">
                                                Sending access
                                                code.</p>
                                    </#if>
                                </div>

                                <!-- Bounce Error Container (Hidden by default) -->
                                <div id="bounce-error-container" class="${properties.kcFormGroupClass!}"
                                    style="display: none; text-align: center; margin-bottom: 20px;">
                                    <span class="${properties.kcInputErrorMessageClass!}"
                                        style="color: red; font-weight: bold; font-size: 1.5em; display: block; margin-bottom: 5px;">
                                        Failed to send access code!</span>
                                    <span class="${properties.kcInputErrorMessageClass!}"
                                        style="color: red; font-size: 1.2em; display: block; margin-bottom: 10px;">
                                        <span id="bounce-error-detail">Email address could not be found.</span>
                                    </span>
                                    <a href="${url.loginRestartFlowUrl}"
                                        class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}"
                                        style="text-decoration: none; margin-top: 20px; font-weight:600;">
                                        Try Again
                                    </a>
                                </div>

                                <form id="kc-otp-login-form" class="${properties.kcFormClass!}"
                                    action="${url.loginAction}" method="post"
                                    style="display: <#if hasError>block<#else>none</#if>;">

                                    <div class="${properties.kcFormGroupClass!}">
                                        <div class="${properties.kcLabelWrapperClass!}">
                                            <label for="emailCode"
                                                class="${properties.kcLabelClass!}">${msg("emailOtpForm")}</label>
                                        </div>

                                        <div class="${properties.kcInputWrapperClass!}">
                                            <input id="emailCode" name="emailCode" autocomplete="off" type="text"
                                                class="${properties.kcInputClass!}" autofocus
                                                aria-invalid="<#if messagesPerField.existsError('emailCode')>true</#if>"
                                                <#if maxAttemptsReached?? && maxAttemptsReached>disabled
        </#if>/>

        <#if messagesPerField.existsError('emailCode')>
            <span id="input-error-otp-code" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                ${kcSanitize(messagesPerField.get('emailCode'))?no_esc}
            </span>
        </#if>
        </div>
        </div>

        <div class="${properties.kcFormGroupClass!}">
            <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                <div class="${properties.kcFormOptionsWrapperClass!}">
                </div>
            </div>

            <div id="kc-form-buttons">
                <div class="${properties.kcFormButtonsWrapperClass!}">
                    <#if !(maxAttemptsReached?? && maxAttemptsReached)>
                        <input
                            class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}"
                            name="login" type="submit" value="Continue" />
                    </#if>
                    <input id="kc-resend-btn" style="margin-left: 15px;"
                        class="${properties.kcButtonClass!} <#if maxAttemptsReached?? && maxAttemptsReached>${properties.kcButtonPrimaryClass!}<#else>${properties.kcButtonDefaultClass!}</#if> ${properties.kcButtonLargeClass!}"
                        name="resend" type="submit" value="${msg('resendCode')}" />
                    <input style="margin-left: 15px;"
                        class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!}"
                        name="cancel" type="submit" value="${msg('doCancel')}" />
                </div>
            </div>
        </div>
        </form>

        <script>
            const userEmail = "${attemptedUserEmail!''}";
            const hasError = <#if hasError>true<#else>false</#if>;
            const showMethodSelection = <#if showMethodSelection>true<#else>false</#if>;
            const deliveryMethod = "${currentMethod}";
            let pollInterval;
            let pollAttempts = 0;
            const maxAttempts = 3; // Wait up to 9 seconds (3 * 3s)

            /* ---- Dots animation for sending text ---- */
            (function () {
                var dots = 1;
                var el = document.getElementById('otp-sending-text');
                var baseText = deliveryMethod === 'sms' ? 'Sending access code via SMS' : 'Sending access code';
                if (el) {
                    setInterval(function () {
                        dots = (dots % 5) + 1;
                        el.textContent = baseText + '.'.repeat(dots);
                    }, 500);
                }
            })();

            /* ---- Resend Cooldown (20 seconds) ---- */
            const COOLDOWN_SEC = 20;
            const COOLDOWN_KEY = 'kc_resend_last_ts';
            let resendInterval;

            function startResendCooldown() {
                const resendBtn = document.getElementById('kc-resend-btn');
                if (!resendBtn) return;

                // Clear any existing timer to prevent overlapping intervals
                if (resendInterval) clearInterval(resendInterval);

                const lastTs = parseInt(sessionStorage.getItem(COOLDOWN_KEY) || '0', 10);
                const now = Date.now();
                const elapsed = Math.floor((now - lastTs) / 1000);
                const remaining = COOLDOWN_SEC - elapsed;

                if (elapsed >= COOLDOWN_SEC) {
                    resendBtn.disabled = false;
                    resendBtn.value = "Resend";
                    return;
                }

                // Still in cooldown
                resendBtn.disabled = true;
                let secondsLeft = remaining > 0 ? remaining : COOLDOWN_SEC;

                function updateLabel() {
                    resendBtn.value = 'Resend in ' + secondsLeft + 's';
                }
                updateLabel();

                resendInterval = setInterval(function () {
                    secondsLeft--;
                    if (secondsLeft <= 0) {
                        clearInterval(resendInterval);
                        resendBtn.disabled = false;
                        resendBtn.value = "Resend";
                    } else {
                        updateLabel();
                    }
                }, 1000);
            }

            // Handle resend behavior
            document.addEventListener('DOMContentLoaded', function () {
                const resendBtn = document.getElementById('kc-resend-btn');
                const otpInput = document.getElementById('emailCode');
                const loginForm = document.getElementById('kc-otp-login-form');

                if (resendBtn) {
                    // Check if we should start cooldown immediately (e.g. page refresh)
                    // But bypass if there's an 'expired' error
                    const errorSpan = document.getElementById('input-error-otp-code');
                    const errorText = errorSpan ? errorSpan.innerText.toLowerCase() : "";

                    if (hasError && errorText.includes('expired')) {
                        resendBtn.disabled = false;
                        resendBtn.value = "Resend";
                        sessionStorage.removeItem(COOLDOWN_KEY);
                    } else {
                        startResendCooldown();
                    }

                    resendBtn.addEventListener('click', function () {
                        sessionStorage.setItem(COOLDOWN_KEY, String(Date.now()));
                        // Disable everything to prevent interactions while sending
                        const allButtons = loginForm.querySelectorAll('input[type="submit"], input[type="button"], button');
                        const allInputs = loginForm.querySelectorAll('input');

                        // Tiny delay so the browser still sends the 'resend' value in the POST request
                        setTimeout(() => {
                            allButtons.forEach(btn => btn.disabled = true);
                            allInputs.forEach(input => input.disabled = true);
                            resendBtn.value = 'Sending...';
                        }, 5);
                    });
                }
            });

            function proceedToOtpForm() {
                clearInterval(pollInterval);
                document.getElementById('loading-container').style.display = 'none';
                document.getElementById('kc-otp-login-form').style.display = 'block';
                // Initialize cooldown when forming is first shown
                sessionStorage.setItem(COOLDOWN_KEY, String(Date.now()));
                startResendCooldown();
            }

            function checkBounceStatus() {
                if (!userEmail) return;
                // Only check bounce for email delivery
                if (deliveryMethod === 'sms') {
                    if (pollAttempts >= maxAttempts) {
                        proceedToOtpForm();
                    }
                    pollAttempts++;
                    return;
                }

                pollAttempts++;
                fetch(`https://192.168.10.20/validateEmail/?email=` + encodeURIComponent(userEmail))
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 'bounced') {
                            // Stop polling, show error
                            clearInterval(pollInterval);
                            document.getElementById('loading-container').style.display = 'none';
                            document.getElementById('kc-otp-login-form').style.display = 'none';
                            document.getElementById('bounce-error-container').style.display = 'block';
                        } else if (pollAttempts >= maxAttempts) {
                            // Time's up, assume successful send
                            proceedToOtpForm();
                        }
                    })
                    .catch(err => {
                        console.error('Polling error', err);
                        // If error fetching and time's up, show OTP form anyway
                        if (pollAttempts >= maxAttempts) {
                            proceedToOtpForm();
                        }
                    });
            }

            // Only poll if not on method selection and no errors
            if (userEmail && !hasError && !showMethodSelection && deliveryMethod !== 'sms') {
                pollInterval = setInterval(checkBounceStatus, 3000);
            }

            // For SMS, auto-proceed after a shorter delay since no bounce check needed
            if (!showMethodSelection && deliveryMethod === 'sms' && !hasError) {
                setTimeout(function () {
                    proceedToOtpForm();
                }, 3000);
            }
        </script>
        </#if>
    </@layout.registrationLayout>