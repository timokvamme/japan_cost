function BenStuff_SpamMe( email, Subject, Message )
%SpamMe( email, subject, message ); notify me via e-mail, please
%   uses junk address 'matlabmailer' which i've set up for this purpose
%   Ben de Haas, 2011
    
    %Initialization; %call initializing script
    
    % Define  variables:
    mail = 'matlabmailer@gmail.com'; %Your GMail email address
    password = 'MatLabMailerPass'; %Your GMail password

    % Then this code will set up the preferences properly:
    setpref('Internet','E_mail',mail);
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username',mail);
    setpref('Internet','SMTP_Password',password);
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');

    % Send the email. Note that the first input is the address you are sending the email to
    sendmail(email, Subject, Message);

end

