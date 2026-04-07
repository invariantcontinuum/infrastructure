<#import "template.ftl" as layout>
<@layout.registrationLayout
    bodyClass="sub-card--idp-link"
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
            <h1 class="sub-form-title">${msg("confirmLinkIdpTitle")}</h1>
            <p class="sub-form-subtitle">Choose how you want to continue with your existing account.</p>
        </div>

        <form id="kc-idp-link-confirm-form" action="${url.loginAction}" method="post">
            <div class="sub-actions">
                <#if !hideReviewButton?has_content>
                    <button
                        type="submit"
                        class="sub-btn sub-btn-secondary"
                        name="submitAction"
                        id="updateProfile"
                        value="updateProfile"
                    >
                        ${msg("confirmLinkIdpReviewProfile")}
                    </button>
                </#if>
                <button
                    type="submit"
                    class="sub-btn"
                    name="submitAction"
                    id="linkAccount"
                    value="linkAccount"
                >
                    ${msg("confirmLinkIdpContinue", idpDisplayName)}
                </button>
            </div>
        </form>
    </#if>

</@layout.registrationLayout>
