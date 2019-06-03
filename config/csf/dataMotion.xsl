<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:loc="http://localhost/"
    exclude-result-prefixes="xs"
    version="1.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
    <xsl:template match="//loc:EmailValidation">
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:loc="http://localhost/">
 <soap:Header/>
 <soap:Body>
     <loc:EmailValidationResponse>
         <loc:EmailValidationResult>
             <loc:OriginalEmail><xsl:value-of select="loc:email/text()"/></loc:OriginalEmail>
             <loc:SuggestedEmail><xsl:value-of select="loc:email/text()"/></loc:SuggestedEmail>
             <loc:ActualEmailValidated><xsl:value-of select="loc:email/text()"/></loc:ActualEmailValidated>
             <loc:SimpleStatus>2</loc:SimpleStatus>
             <loc:StatusCode>2</loc:StatusCode>
             <loc:StatusCodeMessage>Sucesso</loc:StatusCodeMessage>
         </loc:EmailValidationResult>
         <loc:ErrorCode>O endereço de e-mail foi validado até o nível requisitado.</loc:ErrorCode>
     </loc:EmailValidationResponse>
 </soap:Body>
</soap:Envelope>
</xsl:template>
</xsl:stylesheet>