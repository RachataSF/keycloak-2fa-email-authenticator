<#import "template.ftl" as layout>
    <@layout.registrationLayout displayMessage=!messagesPerField.existsError('emailCode'); section>
        <#if section="header">
            ${msg("doLogIn")}
            <#elseif section="form">
                <#assign hasError=messagesPerField.existsError('emailCode') || (maxAttemptsReached?? &&
                    maxAttemptsReached)>

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
                            font-size: 1.25rem !important;
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
                    </style>

                    <!-- Loading Container (Shown on first load) -->
                    <div id="loading-container" class="${properties.kcFormGroupClass!}"
                        style="display: <#if hasError>none<#else>block</#if>; text-align: center; margin-bottom: 20px; padding: 20px 0;">
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
                                font-size: 50px;
                                margin-bottom: 10px;
                                animation: flyEnvelope 2s infinite ease-in-out;
                            }
                        </style>
                        <div class="envelope-icon">
                            <svg fill="#1181e8" width="40px" height="40px" viewBox="0 0 35.00 35.00" data-name="Layer 2"
                                id="ee13b174-13f0-43ea-b921-f168b1054f8d" xmlns="http://www.w3.org/2000/svg"
                                stroke="#1181e8">
                                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                                <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"
                                    stroke="#CCCCCC" stroke-width="0.07"></g>
                                <g id="SVGRepo_iconCarrier">
                                    <path
                                        d="M29.384,30.381H5.615A5.372,5.372,0,0,1,.25,25.015V9.984A5.371,5.371,0,0,1,5.615,4.619H29.384A5.372,5.372,0,0,1,34.75,9.984V25.015A5.372,5.372,0,0,1,29.384,30.381ZM5.615,7.119A2.868,2.868,0,0,0,2.75,9.984V25.015a2.868,2.868,0,0,0,2.865,2.866H29.384a2.869,2.869,0,0,0,2.866-2.866V9.984a2.869,2.869,0,0,0-2.866-2.865Z">
                                    </path>
                                    <path
                                        d="M17.486,20.865a4.664,4.664,0,0,1-2.9-.975L1.218,9.237A1.25,1.25,0,1,1,2.777,7.282L16.141,17.935a2.325,2.325,0,0,0,2.7-.007L32.04,7.287a1.249,1.249,0,1,1,1.569,1.945L20.414,19.873A4.675,4.675,0,0,1,17.486,20.865Z">
                                    </path>
                                </g>
                            </svg>
                        </div>
                        <p id="otp-sending-text"
                            style="font-size: 1.2em; color: #555; font-weight: bold; margin-top: 10px;">Sending access
                            code.</p>
                    </div>

                    <!-- Bounce Error Container (Hidden by default) -->
                    <div id="bounce-error-container" class="${properties.kcFormGroupClass!}"
                        style="display: none; text-align: center; margin-bottom: 20px;">
                        <span class="${properties.kcInputErrorMessageClass!}"
                            style="color: red; font-weight: bold; font-size: 1.5em; display: block; margin-bottom: 5px;">
                            Failed to send access code!</span>
                        <span class="${properties.kcInputErrorMessageClass!}"
                            style="color: red; font-size: 1.2em; display: block; margin-bottom: 10px;">
                            Email address could not be found.
                        </span>
                        <a href="${url.loginRestartFlowUrl}"
                            class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}"
                            style="text-decoration: none; margin-top: 20px; font-weight:600;">
                            Try Again
                        </a>
                    </div>

                    <form id="kc-otp-login-form" class="${properties.kcFormClass!}" action="${url.loginAction}"
                        method="post" style="display: <#if hasError>block<#else>none</#if>;">

                        <div class="${properties.kcFormGroupClass!}">
                            <div class="${properties.kcLabelWrapperClass!}">
                                <label for="emailCode"
                                    class="${properties.kcLabelClass!}">${msg("emailOtpForm")}</label>
                            </div>

                            <div class="${properties.kcInputWrapperClass!}">
                                <input id="emailCode" name="emailCode" autocomplete="off" type="text"
                                    class="${properties.kcInputClass!}" autofocus
                                    aria-invalid="<#if messagesPerField.existsError('emailCode')>true</#if>" <#if
                                    maxAttemptsReached?? && maxAttemptsReached>disabled
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
                            name="login" type="submit" value="${msg('doLogIn')}" />
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
            const hasError = ${ hasError?string('true', 'false')};
            let pollInterval;
            let pollAttempts = 0;
            const maxAttempts = 3; // Wait up to 9 seconds (3 * 3s)

            /* ---- Dots animation for sending text ---- */
            (function () {
                var dots = 1;
                var el = document.getElementById('otp-sending-text');
                if (el) {
                    setInterval(function () {
                        dots = (dots % 5) + 1;
                        el.textContent = 'Sending access code' + '.'.repeat(dots);
                    }, 500);
                }
            })();

            /* ---- Resend Cooldown (30 seconds) ---- */
            const COOLDOWN_SEC = 30;
            const COOLDOWN_KEY = 'kc_resend_last_ts';

            function startResendCooldown() {
                const resendBtn = document.getElementById('kc-resend-btn');
                if (!resendBtn) return;

                const originalValue = resendBtn.defaultValue || '${msg("resendCode")}';
                const lastTs = parseInt(sessionStorage.getItem(COOLDOWN_KEY) || '0', 10);
                const now = Date.now();
                const elapsed = Math.floor((now - lastTs) / 1000);
                const remaining = COOLDOWN_SEC - elapsed;

                if (lastTs === 0 || elapsed >= COOLDOWN_SEC) {
                    // First load OR cooldown already expired — still lock it once
                    // because we just sent a code right now
                    if (lastTs === 0) {
                        sessionStorage.setItem(COOLDOWN_KEY, String(now));
                    }
                    // Expired: unlock immediately if expired
                    if (elapsed >= COOLDOWN_SEC) {
                        resendBtn.disabled = false;
                        resendBtn.value = originalValue;
                        return;
                    }
                }

                // Still in cooldown
                resendBtn.disabled = true;
                let secondsLeft = remaining > 0 ? remaining : COOLDOWN_SEC;

                function updateLabel() {
                    resendBtn.value = 'Wait ' + secondsLeft + 's';
                }
                updateLabel();

                const countdown = setInterval(function () {
                    secondsLeft--;
                    if (secondsLeft <= 0) {
                        clearInterval(countdown);
                        resendBtn.disabled = false;
                        resendBtn.value = originalValue;
                    } else {
                        updateLabel();
                    }
                }, 1000);
            }

            // When the resend button is actually clicked, reset the timestamp
            document.addEventListener('DOMContentLoaded', function () {
                const resendBtn = document.getElementById('kc-resend-btn');
                if (resendBtn) {
                    resendBtn.addEventListener('click', function () {
                        sessionStorage.setItem(COOLDOWN_KEY, String(Date.now()));
                        // Tiny delay so the browser still sends the 'resend' value in the POST request
                        setTimeout(() => {
                            resendBtn.disabled = true;
                            // resendBtn.value = 'Sending...';
                        }, 10);
                    });
                }
            });

            function proceedToOtpForm() {
                clearInterval(pollInterval);
                document.getElementById('loading-container').style.display = 'none';
                document.getElementById('kc-otp-login-form').style.display = 'block';
                // Start cooldown once OTP form is shown
                sessionStorage.setItem(COOLDOWN_KEY, String(Date.now()));
                startResendCooldown();
            }

            function checkBounceStatus() {
                if (!userEmail) return;

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

            // If page was reloaded with an existing error, apply cooldown right away
            if (hasError) {
                startResendCooldown();
            }

            // Only poll if there are no logic errors blocking the initial attempt
            if (userEmail && !hasError) {
                pollInterval = setInterval(checkBounceStatus, 3000);
            }
        </script>
        </#if>
    </@layout.registrationLayout>