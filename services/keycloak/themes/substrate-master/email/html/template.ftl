<#macro emailLayout>
<html lang="${locale.language}" dir="${(ltr)?then('ltr','rtl')}">
<body style="margin:0;padding:24px 12px;background:#EDE8DF;color:#1C1813;font-family:'Instrument Sans',-apple-system,BlinkMacSystemFont,'Segoe UI',Arial,sans-serif;">
  <table role="presentation" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse;">
    <tr>
      <td align="center" style="padding:0;">
        <table role="presentation" cellpadding="0" cellspacing="0" width="100%" style="max-width:620px;border-collapse:separate;background:#FEFCF9;border:1px solid #D4C9BB;border-top:4px solid #1A4A7A;border-radius:8px;overflow:hidden;">
          <tr>
            <td style="padding:24px 28px 12px 28px;">
              <div style="font-size:0;line-height:1;">
                <span style="display:inline-block;width:11px;height:11px;background:#1A4A7A;clip-path:polygon(50% 0%,100% 50%,50% 100%,0% 50%);margin-right:10px;vertical-align:middle;"></span>
                <span style="display:inline-block;vertical-align:middle;font-family:'Fraunces',Georgia,serif;font-style:italic;font-size:30px;font-weight:300;line-height:1;color:#1C1813;">Substrate Master</span>
              </div>
            </td>
          </tr>
          <tr>
            <td style="padding:12px 28px 28px 28px;color:#1C1813;font-size:15px;line-height:1.6;">
              <#nested>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
</#macro>
