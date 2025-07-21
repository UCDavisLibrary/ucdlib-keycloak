<#include "header.ftl">

<div class="login-box">
  <div class="login-heading">
      <svg class="library-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 276.31 432.01"><path d="M102.37,337.79,148,325.38c13.66-3.71,24-17.44,24-31.94V121.15l-69.56-11Z" style="fill:#ffbf00"></path><path d="M171.94,87.9V0L24.87,31.15C10.69,34.15,0,47.81,0,63v302.7l69.55-18.93v-275Z" style="fill:#ffbf00"></path><path d="M250.56,100.25,171.94,87.9v33.26l71.49,11.24V393.6l-141-22.18V337.8l-32.84,8.94v25.48c0,15.3,11.3,29.06,25.72,31.33l181,28.46V131.58C276.27,116.28,265,102.52,250.56,100.25Z" style="fill:#022851"></path></svg>
      <h2>Sign in to ${realm.displayName}</h2>
  </div>

    <form id="kc-otp-login-form" class="${properties.kcFormClass!}" action="${url.loginAction}"
        method="post">
        <#if otpLogin.userOtpCredentials?size gt 1>
            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcInputWrapperClass!}">
                    <#list otpLogin.userOtpCredentials as otpCredential>
                        <input id="kc-otp-credential-${otpCredential?index}" class="${properties.kcLoginOTPListInputClass!}" type="radio" name="selectedCredentialId" value="${otpCredential.id}" <#if otpCredential.id == otpLogin.selectedCredentialId>checked="checked"</#if>>
                        <label for="kc-otp-credential-${otpCredential?index}" class="${properties.kcLoginOTPListClass!}" tabindex="${otpCredential?index}">
                            <span class="${properties.kcLoginOTPListItemHeaderClass!}">
                                <span class="${properties.kcLoginOTPListItemIconBodyClass!}">
                                    <i class="${properties.kcLoginOTPListItemIconClass!}" aria-hidden="true"></i>
                                </span>
                                <span class="${properties.kcLoginOTPListItemTitleClass!}">${otpCredential.userLabel}</span>
                            </span>
                        </label>
                    </#list>
                </div>
            </div>
        </#if>

        <div class="${properties.kcFormGroupClass!}">
            <div class="${properties.kcLabelWrapperClass!}">
                <label for="otp" class="${properties.kcLabelClass!}">${msg("loginOtpOneTime")}</label>
            </div>

        <div class="${properties.kcInputWrapperClass!} field-container">
            <input id="otp" name="otp" autocomplete="off" type="text" class="${properties.kcInputClass!}"
                    autofocus aria-invalid="<#if messagesPerField.existsError('totp')>true</#if>"/>

            <#if messagesPerField.existsError('totp')>
                <span id="input-error-otp-code" class="${properties.kcInputErrorMessageClass!}"
                        aria-live="polite">
                    ${kcSanitize(messagesPerField.get('totp'))?no_esc}
                </span>
            </#if>
        </div>
    </div>

        <div class="${properties.kcFormGroupClass!}">
            <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                <div class="${properties.kcFormOptionsWrapperClass!}">
                </div>
            </div>

            <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!} field-container">
                <input
                    class="btn btn--block"
                    name="login" id="kc-login" type="submit" value="${msg("doLogIn")}" />
            </div>
        </div>
    </form>
</div>

<#include "footer.ftl">
