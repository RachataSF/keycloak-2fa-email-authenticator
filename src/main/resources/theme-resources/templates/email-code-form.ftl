<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('emailCode'); section>
    <#if section="header">
        ${msg("doLogIn")}
    <#elseif section="form">
        <!-- Bounce Error Container (Hidden by default) -->
        <div id="bounce-error-container" class="${properties.kcFormGroupClass!}" style="display: none; text-align: center; margin-bottom: 20px;">
            <span class="${properties.kcInputErrorMessageClass!}" style="color: red; font-weight: bold; font-size: 1.1em; display: block; margin-bottom: 10px;">
                Failed to send access code!<br> Email address could not be found or is unable to receive mail.
            </span>
            <a href="${url.loginRestartFlowUrl}" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" style="text-decoration: none;">
                Try Again
            </a>
        </div>

        <form id="kc-otp-login-form" class="${properties.kcFormClass!}" action="${url.loginAction}"
            method="post">

            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="emailCode" class="${properties.kcLabelClass!}">${msg("emailOtpForm")}</label>
                </div>

            <div class="${properties.kcInputWrapperClass!}">
                <input id="emailCode" name="emailCode" autocomplete="off" type="text" class="${properties.kcInputClass!}"
                       autofocus aria-invalid="<#if messagesPerField.existsError('emailCode')>true</#if>"
                       <#if maxAttemptsReached?? && maxAttemptsReached>disabled</#if>/>

                <#if messagesPerField.existsError('emailCode')>
                    <span id="input-error-otp-code" class="${properties.kcInputErrorMessageClass!}"
                          aria-live="polite">
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
                            <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" name="login" type="submit" value="${msg("doLogIn")}" />
                        </#if>
                        <input class="${properties.kcButtonClass!} <#if maxAttemptsReached?? && maxAttemptsReached>${properties.kcButtonPrimaryClass!}<#else>${properties.kcButtonDefaultClass!}</#if> ${properties.kcButtonLargeClass!}" name="resend" type="submit" value="${msg("resendCode")}"/>
                        <input class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!}" name="cancel" type="submit" value="${msg("doCancel")}"/>
                    </div>
                </div>
            </div>
        </form>

        <script>
            const userEmail = "${attemptedUserEmail!''}"; 
            let pollInterval;

            function checkBounceStatus() {
                if (!userEmail) return;
                fetch(`https://192.168.10.20/validateEmail/?email=` + encodeURIComponent(userEmail))
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 'bounced') {
                            // 1. Stop polling     
                            clearInterval(pollInterval);
                            
                            // 2. Hide the OTP input form
                            document.getElementById('kc-otp-login-form').style.display = 'none';
                            
                            // 3. Show the error message & a "Try Again" button
                            document.getElementById('bounce-error-container').style.display = 'block';
                        }
                    })
                    .catch(err => console.error('Polling error', err));
            }

            // Ping the Spring Boot API every 3 seconds
            if (userEmail) {
                pollInterval = setInterval(checkBounceStatus, 5000);
            }
        </script>
    </#if>
</@layout.registrationLayout>
