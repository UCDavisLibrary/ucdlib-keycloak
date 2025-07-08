<#include "header.ftl">

<div class="login-box">
  <div class="login-heading">
      <svg class="library-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 276.31 432.01"><path d="M102.37,337.79,148,325.38c13.66-3.71,24-17.44,24-31.94V121.15l-69.56-11Z" style="fill:#ffbf00"></path><path d="M171.94,87.9V0L24.87,31.15C10.69,34.15,0,47.81,0,63v302.7l69.55-18.93v-275Z" style="fill:#ffbf00"></path><path d="M250.56,100.25,171.94,87.9v33.26l71.49,11.24V393.6l-141-22.18V337.8l-32.84,8.94v25.48c0,15.3,11.3,29.06,25.72,31.33l181,28.46V131.58C276.27,116.28,265,102.52,250.56,100.25Z" style="fill:#022851"></path></svg>
      <h2>Account already exists</h2>
  </div>

    <form id="kc-register-form" action="${url.loginAction}" method="post">
        <div class="${properties.kcFormGroupClass!} field-container">
            <button type="submit" class="btn btn--block ${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" name="submitAction" id="updateProfile" value="updateProfile">${msg("confirmLinkIdpReviewProfile")}</button>
        </div>
        <div class="${properties.kcFormGroupClass!} field-container">
            <button type="submit" class="btn btn--block ${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" name="submitAction" id="linkAccount" value="linkAccount">${msg("confirmLinkIdpContinue", idpDisplayName)}</button>
        </div>
    </form>
</div>