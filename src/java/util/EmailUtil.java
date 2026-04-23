package util;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

public class EmailUtil {

    private static final String FROM_EMAIL = "gonzagafernando077@gmail.com";  // YOUR EMAIL
    private static final String FROM_PASSWORD = "njomfunsxxdwmwzo";   // YOUR APP PASSWORD (NOT regular password)
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";

    public static boolean sendOTPEmailHTML(String toEmail, String otp) {
        String subject  = "Your OTP Code - TIP-SC";
        String htmlBody =
            "<html><body style='font-family:Arial,sans-serif;background:#f4f4f4;padding:20px;'>" +
            "<div style='background:#fff;padding:30px;border-radius:8px;max-width:500px;margin:0 auto;'>" +
            "<h2 style='color:#333;'>Email Verification</h2>" +
            "<p style='color:#666;'>Your OTP verification code is:</p>" +
            "<div style='background:#C8A800;color:#fff;padding:15px;text-align:center;" +
            "font-size:28px;font-weight:bold;border-radius:5px;letter-spacing:6px;'>" +
            otp + "</div>" +
            "<p style='color:#666;margin-top:20px;'>This code expires in <strong>10 minutes</strong>.</p>" +
            "<p style='color:#999;font-size:12px;'>Do not share this code with anyone.</p>" +
            "<hr style='border:none;border-top:1px solid #ddd;margin-top:30px;'/>" +
            "<p style='color:#999;font-size:12px;'>TIP-SC System</p>" +
            "</div></body></html>";

        return sendHtmlEmail(toEmail, subject, htmlBody);
    }

    // ── Called by VerifyOTPServlet after RESET OTP is confirmed ──────────────
    public static boolean sendTempPassword(String toEmail, String tempPassword) {
        String subject = "TIP-SC | Your New Temporary Password";
        String body =
            "<div style='font-family:Arial,sans-serif;max-width:520px;margin:auto;" +
            "border:1px solid #e0e0e0;border-radius:10px;overflow:hidden;'>" +

            "<div style='background:#e4bf05;padding:28px 32px;'>" +
            "  <div style='font-size:1.1rem;font-weight:800;letter-spacing:.06em;color:#111;'>" +
            "    TIP-SC</div>" +
            "  <div style='font-size:.85rem;color:#333;margin-top:4px;'>" +
            "    Student Concern Management System</div>" +
            "</div>" +

            "<div style='padding:32px;background:#fff;'>" +
            "  <p style='font-size:.95rem;color:#111;margin-bottom:16px;'>Hello,</p>" +
            "  <p style='font-size:.88rem;color:#444;line-height:1.6;margin-bottom:20px;'>" +
            "    A new temporary password has been generated for your account." +
            "    Use it to sign in, then you will be prompted to create a permanent password." +
            "  </p>" +

            "  <div style='background:#f5f5f5;border:1.5px dashed #ccc;border-radius:8px;" +
            "    padding:18px 24px;text-align:center;margin-bottom:20px;'>" +
            "    <div style='font-size:.72rem;color:#888;letter-spacing:.06em;" +
            "      margin-bottom:6px;'>TEMPORARY PASSWORD</div>" +
            "    <div style='font-size:1.6rem;font-weight:800;letter-spacing:.12em;" +
            "      color:#111;font-family:monospace;'>" +
            tempPassword +
            "    </div>" +
            "    <div style='font-size:.72rem;color:#e44;margin-top:8px;'>" +
            "      Expires in 10 minutes</div>" +
            "  </div>" +

            "  <p style='font-size:.8rem;color:#888;line-height:1.6;'>" +
            "    If you did not request this, please contact your system administrator immediately." +
            "  </p>" +
            "</div>" +

            "<div style='background:#f9f9f9;padding:14px 32px;" +
            "  border-top:1px solid #eee;font-size:.72rem;color:#aaa;'>" +
            "  &copy; 2026 TIP-Manila SCMS &nbsp;&bull;&nbsp; Do not reply to this email." +
            "</div>" +

            "</div>";

        return sendHtmlEmail(toEmail, subject, body);
    }

    public static boolean sendHtmlEmail(String toEmail, String subject, String htmlBody) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.host",             SMTP_HOST);
            props.put("mail.smtp.port",             SMTP_PORT);
            props.put("mail.smtp.auth",             "true");
            props.put("mail.smtp.starttls.enable",  "true");
            props.put("mail.smtp.starttls.required","true");

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, FROM_PASSWORD);
                }
            });

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("Email sent to: " + toEmail);
            return true;

        } catch (MessagingException e) {
            System.err.println("Failed to send email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}