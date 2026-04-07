<#import "template.ftl" as layout>
<#import "user-profile-commons.ftl" as userProfileCommons>
<@layout.registrationLayout
    bodyClass="sub-card--profile-review"
    displayMessage=messagesPerField.exists('global'); section>

    <#if section = "form">

        <#if realm.internationalizationEnabled && locale.supported?size gt 1>
            <div class="sub-locale">
                <select onchange="window.location.href=this.value" class="sub-locale-select" aria-label="Language">
                    <#list locale.supported as l>
                        <option value="${l.url}" <#if l.selected>selected</#if>>${l.label}</option>
                    </#list>
                </select>
            </div>
        </#if>

        <div class="sub-form-intro">
            <h1 class="sub-form-title">${msg("loginProfileTitle")}</h1>
            <p class="sub-form-subtitle">Review your profile details before continuing.</p>
        </div>

        <form id="kc-update-profile-form" class="sub-user-profile-form" action="${url.loginAction}" method="post">
            <@userProfileCommons.userProfileFormFields/>
            <div class="sub-actions">
                <button type="submit" class="sub-btn">${msg("doSubmit")}</button>
                <#if isAppInitiatedAction??>
                    <button type="submit" class="sub-btn sub-btn-secondary" name="cancel-aia" value="true" formnovalidate>
                        ${msg("doCancel")}
                    </button>
                </#if>
            </div>
        </form>
    </#if>

</@layout.registrationLayout>
