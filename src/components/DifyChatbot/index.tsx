import React, { useEffect } from "react";

function DifyChatbot() {
  useEffect(() => {
    const script = document.createElement("script");
    script.innerHTML = `
      window.difyChatbotConfig = {
        token: 'h8yGoAkqwiVB4yXc'
      };
    `;
    document.body.appendChild(script);

    const chatbotScript = document.createElement("script");
    chatbotScript.src = "/dify/embed.min.js";
    chatbotScript.id = "h8yGoAkqwiVB4yXc";
    chatbotScript.defer = true;
    document.body.appendChild(chatbotScript);
  }, []);

  return null;
}

export default DifyChatbot;
