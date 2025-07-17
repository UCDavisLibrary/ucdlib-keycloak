<#import "password-commons.ftl" as passwordCommons>
<#include "header.ftl">

<div class="login-box">
    <div class="login-heading">
        <svg class="library-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 276.31 432.01"><path d="M102.37,337.79,148,325.38c13.66-3.71,24-17.44,24-31.94V121.15l-69.56-11Z" style="fill:#ffbf00"></path><path d="M171.94,87.9V0L24.87,31.15C10.69,34.15,0,47.81,0,63v302.7l69.55-18.93v-275Z" style="fill:#ffbf00"></path><path d="M250.56,100.25,171.94,87.9v33.26l71.49,11.24V393.6l-141-22.18V337.8l-32.84,8.94v25.48c0,15.3,11.3,29.06,25.72,31.33l181,28.46V131.58C276.27,116.28,265,102.52,250.56,100.25Z" style="fill:#022851"></path></svg>
        <h2>Sign in to ${realm.displayName}</h2>
    </div>

    <hr class="divider"/>

    <ol id="kc-totp-settings">
        <li>
            <p>${msg("loginTotpStep1")}</p>

            <ul class="list--arrow">
                <#list totp.supportedApplications as app>
                    <li>${msg(app)}</li>
                </#list>
            </ul>
        </li>

        <#if mode?? && mode = "manual">
            <li>
                <p>${msg("loginTotpManualStep2")}</p>
                <p><span id="kc-totp-secret-key">${totp.totpSecretEncoded}</span></p>
                <p><a href="${totp.qrUrl}" id="mode-barcode">${msg("loginTotpScanBarcode")}</a></p>
            </li>
            <li>
                <p>${msg("loginTotpManualStep3")}</p>
                <p>
                <ul class="list--arrow">
                    <li id="kc-totp-type">${msg("loginTotpType")}: ${msg("loginTotp." + totp.policy.type)}</li>
                    <li id="kc-totp-algorithm">${msg("loginTotpAlgorithm")}: ${totp.policy.getAlgorithmKey()}</li>
                    <li id="kc-totp-digits">${msg("loginTotpDigits")}: ${totp.policy.digits}</li>
                    <#if totp.policy.type = "totp">
                        <li id="kc-totp-period">${msg("loginTotpInterval")}: ${totp.policy.period}</li>
                    <#elseif totp.policy.type = "hotp">
                        <li id="kc-totp-counter">${msg("loginTotpCounter")}: ${totp.policy.initialCounter}</li>
                    </#if>
                </ul>
                </p>
            </li>
        <#else>
            <li>
                <p>${msg("loginTotpStep2")}</p>
                <img id="kc-totp-secret-qr-code" src="data:image/png;base64, ${totp.totpSecretQrCode}" alt="Figure: Barcode"><br/>
                <p><a href="${totp.manualUrl}" id="mode-manual">${msg("loginTotpUnableToScan")}</a></p>
            </li>
        </#if>
        <li>
            <p>${msg("loginTotpStep3")}</p>
            <p>${msg("loginTotpStep3DeviceName")}</p>
        </li>
    </ol>

    <form action="${url.loginAction}" class="${properties.kcFormClass!}" id="kc-totp-settings-form" method="post">
        <div class="${properties.kcFormGroupClass!}">
            <div class="${properties.kcInputWrapperClass!}" style="display: flex;">
                <label for="totp" class="control-label">${msg("authenticatorCode")}</label> <span class="required">*</span>
            </div>
            <div class="${properties.kcInputWrapperClass!}">
                <input type="text" id="totp" name="totp" autocomplete="off" class="${properties.kcInputClass!}"
                        aria-invalid="<#if messagesPerField.existsError('totp')>true</#if>"
                />

                <#if messagesPerField.existsError('totp')>
                    <span id="input-error-otp-code" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                        ${kcSanitize(messagesPerField.get('totp'))?no_esc}
                    </span>
                </#if>

            </div>
            <input type="hidden" id="totpSecret" name="totpSecret" value="${totp.totpSecret}" />
            <#if mode??><input type="hidden" id="mode" name="mode" value="${mode}"/></#if>
        </div>

        <div class="${properties.kcFormGroupClass!}">
            <div class="${properties.kcInputWrapperClass!} field-container" style="display: flex;">
                <label for="userLabel" class="control-label">${msg("loginTotpDeviceName")}</label> <#if totp.otpCredentials?size gte 1><span class="required">*</span></#if>
            </div>

            <div class="${properties.kcInputWrapperClass!} field-container">
                <input type="text" class="${properties.kcInputClass!}" id="userLabel" name="userLabel" autocomplete="off"
                        aria-invalid="<#if messagesPerField.existsError('userLabel')>true</#if>"
                />

                <#if messagesPerField.existsError('userLabel')>
                    <span id="input-error-otp-label" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                        ${kcSanitize(messagesPerField.get('userLabel'))?no_esc}
                    </span>
                </#if>
            </div>
        </div>

        <#if isAppInitiatedAction??>
            <input type="submit"
                    class="btn btn--block ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}"
                    id="saveTOTPBtn" value="${msg("doSubmit")}"
            />
            <button type="submit"
                    class="btn btn--block ${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!}"
                    id="cancelTOTPBtn" name="cancel-aia" value="true" />${msg("doCancel")}
            </button>
        <#else>
            <input type="submit"
                    class="btn btn--block ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"
                    id="saveTOTPBtn" value="${msg("doSubmit")}"
            />
        </#if>
    </form>
</div>

<#include "footer.ftl">