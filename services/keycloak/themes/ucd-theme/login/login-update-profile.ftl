<#include "header.ftl">

<div class="login-box">
  <div class="login-heading">
      <svg class="library-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 276.31 432.01"><path d="M102.37,337.79,148,325.38c13.66-3.71,24-17.44,24-31.94V121.15l-69.56-11Z" style="fill:#ffbf00"></path><path d="M171.94,87.9V0L24.87,31.15C10.69,34.15,0,47.81,0,63v302.7l69.55-18.93v-275Z" style="fill:#ffbf00"></path><path d="M250.56,100.25,171.94,87.9v33.26l71.49,11.24V393.6l-141-22.18V337.8l-32.84,8.94v25.48c0,15.3,11.3,29.06,25.72,31.33l181,28.46V131.58C276.27,116.28,265,102.52,250.56,100.25Z" style="fill:#022851"></path></svg>
      <h2>Sign in to ${realm.displayName}</h2>
  </div>

    <form id="kc-update-profile-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
        <#if user.editUsernameAllowed>
            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="username" class="${properties.kcLabelClass!}">${msg("username")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!} field-container">
                    <input type="text" id="username" name="username" value="${(user.username!'')}"
                            class="${properties.kcInputClass!}"
                            aria-invalid="<#if messagesPerField.existsError('username')>true</#if>"
                    />

                    <#if messagesPerField.existsError('username')>
                        <span id="input-error-username" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('username'))?no_esc}
                        </span>
                    </#if>
                </div>
            </div>
        </#if>
        <#if user.editEmailAllowed>
            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="email" class="${properties.kcLabelClass!}">${msg("email")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!} field-container">
                    <input type="text" id="email" name="email" value="${(user.email!'')}"
                            class="${properties.kcInputClass!}"
                            aria-invalid="<#if messagesPerField.existsError('email')>true</#if>"
                    />

                    <#if messagesPerField.existsError('email')>
                        <span id="input-error-email" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('email'))?no_esc}
                        </span>
                    </#if>
                </div>
            </div>
        </#if>

        <div class="${properties.kcFormGroupClass!}">
            <div class="${properties.kcLabelWrapperClass!}">
                <label for="firstName" class="${properties.kcLabelClass!}">${msg("firstName")}</label>
            </div>
            <div class="${properties.kcInputWrapperClass!} field-container">
                <input type="text" id="firstName" name="firstName" value="${(user.firstName!'')}"
                        class="${properties.kcInputClass!}"
                        aria-invalid="<#if messagesPerField.existsError('firstName')>true</#if>"
                />

                <#if messagesPerField.existsError('firstName')>
                    <span id="input-error-firstname" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                        ${kcSanitize(messagesPerField.get('firstName'))?no_esc}
                    </span>
                </#if>
            </div>
        </div>

        <div class="${properties.kcFormGroupClass!}">
            <div class="${properties.kcLabelWrapperClass!}">
                <label for="lastName" class="${properties.kcLabelClass!}">${msg("lastName")}</label>
            </div>
            <div class="${properties.kcInputWrapperClass!} field-container">
                <input type="text" id="lastName" name="lastName" value="${(user.lastName!'')}"
                        class="${properties.kcInputClass!}"
                        aria-invalid="<#if messagesPerField.existsError('lastName')>true</#if>"
                />

                <#if messagesPerField.existsError('lastName')>
                    <span id="input-error-lastname" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                        ${kcSanitize(messagesPerField.get('lastName'))?no_esc}
                    </span>
                </#if>
            </div>
        </div>

        <div class="${properties.kcFormGroupClass!}">
            <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                <div class="${properties.kcFormOptionsWrapperClass!}">
                </div>
            </div>

            <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                <#if isAppInitiatedAction??>
                <input class="btn btn--block ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}" />
                <button class="btn btn--block ${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!}" type="submit" name="cancel-aia" value="true" />${msg("doCancel")}</button>
                <#else>
                <input class="btn btn--block ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}" />
                </#if>
            </div>
        </div>
    </form>
</div>

<#include "footer.ftl">
