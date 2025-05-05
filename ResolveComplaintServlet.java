import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.logging.*;

@WebServlet("/ResolveComplaintServlet")
public class ResolveComplaintServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger(ResolveComplaintServlet.class.getName());

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String complaintId = request.getParameter("complaint_id");

        // Validate complaint ID to prevent SQL Injection
        if (complaintId == null || !complaintId.matches("\\d+")) {
            response.getWriter().println("Invalid Complaint ID");
            return;
        }

        Connection con = null;
        PreparedStatement updateStmt = null, emailStmt = null;
        ResultSet rs = null;

        try {
            // Establish Database Connection using DBConnection helper class
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // Start transaction

            // Get student's email & complaint details
            String emailQuery = "SELECT u.email, c.complaint_text, c.department FROM complaints c " +
                                "JOIN users u ON c.user_id = u.id WHERE c.complaint_id = ?";
            emailStmt = con.prepareStatement(emailQuery);
            emailStmt.setInt(1, Integer.parseInt(complaintId));
            rs = emailStmt.executeQuery();

            String studentEmail = null, complaintText = null, department = null;

            if (rs.next()) {
                studentEmail = rs.getString("email");
                complaintText = rs.getString("complaint_text");
                department = rs.getString("department");
            } else {
                response.getWriter().println("Complaint not found");
                return;
            }

            // Update the complaint's status and set resolution timestamp
            String updateSql = "UPDATE complaints SET status = 'Resolved', resolved_at = ? WHERE complaint_id = ?";
            updateStmt = con.prepareStatement(updateSql);
            updateStmt.setString(1, getCurrentTimestamp());
            updateStmt.setInt(2, Integer.parseInt(complaintId));
            int rowsAffected = updateStmt.executeUpdate();

            if (rowsAffected > 0 && studentEmail != null) {
                sendEmail(studentEmail, complaintId, complaintText, department);
                con.commit(); // Commit transaction only if everything is successful
                response.sendRedirect("AdminDashboardServlet?success=Complaint+Resolved");
            } else {
                con.rollback(); // Rollback if no rows were updated
                response.getWriter().println("Error updating complaint");
            }

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error resolving complaint", e);
            response.getWriter().println("Error: " + e.getMessage());
            try {
                if (con != null) con.rollback(); // Rollback on error
            } catch (SQLException rollbackEx) {
                logger.log(Level.SEVERE, "Rollback failed", rollbackEx);
            }
        } finally {
            try {
                if (rs != null) rs.close();
                if (emailStmt != null) emailStmt.close();
                if (updateStmt != null) updateStmt.close();
                if (con != null) con.close();
            } catch (SQLException closeEx) {
                logger.log(Level.WARNING, "Error closing resources", closeEx);
            }
        }
    }

    private void sendEmail(String recipientEmail, String complaintId, String complaintText, String department) {
        final String senderEmail = "your-email@example.com";
        final String senderPassword = "your-email-password";

        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");

        Session session = Session.getInstance(properties, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, senderPassword);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(senderEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Complaint Resolved - ID: " + complaintId);

            String emailBody = "<p>Dear Student,</p>" +
                    "<p>Your complaint has been successfully resolved.</p>" +
                    "<p><strong>Complaint ID:</strong> " + complaintId + "<br>" +
                    "<strong>Department:</strong> " + department + "<br>" +
                    "<strong>Issue:</strong> " + complaintText + "<br>" +
                    "<strong>Status:</strong> Resolved</p>" +
                    "<p>Thank you for using the University Complaint Management System.</p>";

            message.setContent(emailBody, "text/html");
            Transport.send(message);
        } catch (MessagingException e) {
            logger.log(Level.SEVERE, "Failed to send email", e);
        }
    }

    private String getCurrentTimestamp() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }
}
