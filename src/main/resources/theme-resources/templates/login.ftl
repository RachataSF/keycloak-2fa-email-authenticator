<#import "template.ftl" as layout>
    <@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password')
        displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>
        <#if section="header">
            ${msg("loginAccountTitle")}
            <#elseif section="form">
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
                        color: #757575 !important;
                        padding-left: 15px !important;
                        display: block;
                        text-align: left;
                        font-size: 0.8rem !important;
                        margin-bottom: 5px !important;
                        margin-top: 15px !important;
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
                        box-sizing: border-box !important;
                        font-size: 1rem !important;
                        margin-top: 10px !important;
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
                    .pf-c-form__helper-text--error,
                    .kcInputErrorMessageClass {
                        color: #e53935 !important;
                        font-size: 0.85rem !important;
                        font-weight: 500 !important;
                        margin-top: 4px !important;
                        display: block !important;
                        padding-left: 15px !important;
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

                    #kc-form-buttons {
                        margin-top: 30px !important;
                        display: flex !important;
                        justify-content: center !important;
                        width: 100%;
                    }

                    #kc-login-text {
                        font-weight: 600;
                    }

                    @keyframes spin {
                        from {
                            transform: rotate(0deg);
                        }

                        to {
                            transform: rotate(360deg);
                        }
                    }
                </style>

                <div id="kc-form">
                    <!-- Sending Access Code Overlay (hidden until login clicked) -->
                    <div id="login-sending-overlay" style="display: none; text-align: center; padding: 30px 0;">
                        <div style="display: inline-block; margin-bottom: 16px;">
                            <svg style="width: 48px; height: 48px; animation: spin 1s linear infinite; color: #0ea5e9;"
                                xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                <circle style="opacity: 0.25;" cx="12" cy="12" r="10" stroke="currentColor"
                                    stroke-width="4"></circle>
                                <path style="opacity: 0.75;" fill="currentColor"
                                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                                </path>
                            </svg>
                        </div>
                        <!-- <p id="login-sending-text"
                            style="font-size: 1.2em; color: #555; font-weight: bold; margin-top: 10px;">Sending access
                            code.</p> -->
                    </div>
                    <!-- <script>
                        (function () {
                            var dots = 1;
                            var el = document.getElementById('login-sending-text');
                            if (el) {
                                setInterval(function () {
                                    dots = (dots % 5) + 1;
                                    el.textContent = 'Sending access code' + '.'.repeat(dots);
                                }, 500);
                            }
                        })();
                    </script> -->
                    <div id="kc-form-wrapper">
                        <#if realm.password>
                            <form id="kc-form-login" onsubmit="return handleLoginSubmit();" action="${url.loginAction}"
                                method="post">

                                <div class="${properties.kcFormGroupClass!}">
                                    <label for="username" class="${properties.kcLabelClass!}">
                                        <#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif
                                                !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>
                                                    ${msg("email")}</#if>
                                    </label>
                                    <div class="${properties.kcInputWrapperClass!}">
                                        <input tabindex="1" id="username" class="${properties.kcInputClass!}"
                                            name="username" value="${(login.username!'')}" type="text" autofocus
                                            autocomplete="off"
                                            aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                                        <#if messagesPerField.existsError('username','password')>
                                            <span id="input-error" class="${properties.kcInputErrorMessageClass!}"
                                                aria-live="polite">
                                                ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                                            </span>
                                        </#if>
                                    </div>
                                </div>

                                <div class="${properties.kcFormGroupClass!}">
                                    <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>
                                    <div class="${properties.kcInputWrapperClass!}">
                                        <input tabindex="2" id="password" class="${properties.kcInputClass!}"
                                            name="password" type="password" autocomplete="off"
                                            aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                                    </div>
                                </div>

                                <div class="${properties.kcFormGroupClass!} ${properties.kcFormSettingClass!}">
                                    <div id="kc-form-options">
                                        <#if realm.rememberMe && !usernameHidden??>
                                            <div class="checkbox">
                                                <label>
                                                    <#if login.rememberMe??>
                                                        <input tabindex="3" id="rememberMe" name="rememberMe"
                                                            type="checkbox" checked> ${msg("rememberMe")}
                                                        <#else>
                                                            <input tabindex="3" id="rememberMe" name="rememberMe"
                                                                type="checkbox"> ${msg("rememberMe")}
                                                    </#if>
                                                </label>
                                            </div>
                                        </#if>
                                    </div>
                                    <div class="${properties.kcFormOptionsWrapperClass!}">
                                        <#if realm.resetPasswordAllowed>
                                            <span><a tabindex="5"
                                                    href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></span>
                                        </#if>
                                    </div>
                                </div>

                                <div id="kc-form-buttons" class="${properties.kcFormGroupClass!}">
                                    <button tabindex="4"
                                        style="display: flex; align-items: center; justify-content: center; gap: 8px;"
                                        class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"
                                        name="login" id="kc-login" type="submit">
                                        <span id="kc-login-text">${msg('doLogIn')}</span>
                                        <span id="kc-login-icon" style="display: inline-block; vertical-align: middle;">
                                            <svg style="width: 1.25rem; height: 1.25rem; display: block;"
                                                viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                                                <g id="SVGRepo_tracerCarrier" stroke-linecap="round"
                                                    stroke-linejoin="round"></g>
                                                <g id="SVGRepo_iconCarrier">
                                                    <path
                                                        d="M13 2C10.2386 2 8 4.23858 8 7C8 7.55228 8.44772 8 9 8C9.55228 8 10 7.55228 10 7C10 5.34315 11.3431 4 13 4H17C18.6569 4 20 5.34315 20 7V17C20 18.6569 18.6569 20 17 20H13C11.3431 20 10 18.6569 10 17C10 16.4477 9.55228 16 9 16C8.44772 16 8 16.4477 8 17C8 19.7614 10.2386 22 13 22H17C19.7614 22 22 19.7614 22 17V7C22 4.23858 19.7614 2 17 2H13Z"
                                                        fill="currentColor"></path>
                                                    <path
                                                        d="M3 11C2.44772 11 2 11.4477 2 12C2 12.5523 2.44772 13 3 13H11.2821C11.1931 13.1098 11.1078 13.2163 11.0271 13.318C10.7816 13.6277 10.5738 13.8996 10.427 14.0945C10.3536 14.1921 10.2952 14.2705 10.255 14.3251L10.2084 14.3884L10.1959 14.4055L10.1915 14.4115C10.1914 14.4116 10.191 14.4122 11 15L10.1915 14.4115C9.86687 14.8583 9.96541 15.4844 10.4122 15.809C10.859 16.1336 11.4843 16.0346 11.809 15.5879L11.8118 15.584L11.822 15.57L11.8638 15.5132C11.9007 15.4632 11.9553 15.3897 12.0247 15.2975C12.1637 15.113 12.3612 14.8546 12.5942 14.5606C13.0655 13.9663 13.6623 13.2519 14.2071 12.7071L14.9142 12L14.2071 11.2929C13.6623 10.7481 13.0655 10.0337 12.5942 9.43937C12.3612 9.14542 12.1637 8.88702 12.0247 8.7025C11.9553 8.61033 11.9007 8.53682 11.8638 8.48679L11.822 8.43002L11.8118 8.41602L11.8095 8.41281C11.4848 7.96606 10.859 7.86637 10.4122 8.19098C9.96541 8.51561 9.86636 9.14098 10.191 9.58778L11 9C10.191 9.58778 10.1909 9.58773 10.191 9.58778L10.1925 9.58985L10.1959 9.59454L10.2084 9.61162L10.255 9.67492C10.2952 9.72946 10.3536 9.80795 10.427 9.90549C10.5738 10.1004 10.7816 10.3723 11.0271 10.682C11.1078 10.7837 11.1931 10.8902 11.2821 11H3Z"
                                                        fill="currentColor"></path>
                                                </g>
                                            </svg>
                                        </span>
                                        <span id="kc-login-spinner" style="display: none;">
                                            <svg style="animation: spin 1s linear infinite; width: 1.25rem; height: 1.25rem;"
                                                xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                                <circle style="opacity: 0.25;" cx="12" cy="12" r="10"
                                                    stroke="currentColor" stroke-width="4"></circle>
                                                <path style="opacity: 0.75;" fill="currentColor"
                                                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                                                </path>
                                            </svg>
                                        </span>
                                    </button>
                                </div>
                            </form>
                            <script>
                                function handleLoginSubmit() {
                                    // Hide the login form, show sending overlay
                                    document.getElementById('kc-form-wrapper').style.display = 'none';
                                    document.getElementById('login-sending-overlay').style.display = 'block';
                                    // Hide page title
                                    const pageTitle = document.getElementById('kc-page-title');
                                    if (pageTitle) pageTitle.style.display = 'none';
                                    // Submit normally
                                    return true;
                                }
                            </script>
                        </#if>
                    </div>
                </div>

                <#elseif section="info">
                    <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                        <div id="kc-registration-container">
                            <div id="kc-registration">
                                <span>${msg("noAccount")} <a tabindex="6"
                                        href="${url.registrationUrl}">${msg("doRegister")}</a></span>
                            </div>
                        </div>
                    </#if>
        </#if>
    </@layout.registrationLayout>