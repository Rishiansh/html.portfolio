import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/AdminDashboardServlet")
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Simple Complaint bean
    public static class Complaint {
        private int complaintId;
        private String studentName;
        private String email;
        private String department;
        private String complaintText;
        private String status;
        private String imagePath;
        private Timestamp submissionDate;
        
        // Getters and setters
        public int getComplaintId() { return complaintId; }
        public void setComplaintId(int complaintId) { this.complaintId = complaintId; }
        
        public String getStudentName() { return studentName; }
        public void setStudentName(String studentName) { this.studentName = studentName; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getDepartment() { return department; }
        public void setDepartment(String department) { this.department = department; }
        
        public String getComplaintText() { return complaintText; }
        public void setComplaintText(String complaintText) { this.complaintText = complaintText; }
        
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        
        public String getImagePath() { return imagePath; }
        public void setImagePath(String imagePath) { this.imagePath = imagePath; }
        
        public Timestamp getSubmissionDate() { return submissionDate; }
        public void setSubmissionDate(Timestamp submissionDate) { this.submissionDate = submissionDate; }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Complaint> complaints = new ArrayList<>();
        
        // Retrieve filter parameters (if provided)
        String filterDept = request.getParameter("filterDept");
        String startDate  = request.getParameter("startDate");
        String endDate    = request.getParameter("endDate");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/university_complaints", "root", "sathi");
            
            // Build dynamic SQL query
            StringBuilder sql = new StringBuilder(
                "SELECT c.complaint_id, u.name AS student_name, u.email, " +
                "c.department, c.complaint_text, c.status, c.image_path, c.submission_date " +
                "FROM complaints c JOIN users u ON c.user_id = u.id"
            );
            List<Object> params = new ArrayList<>();
            boolean whereAdded = false;
            
            // Add department filter if provided
            if (filterDept != null && !filterDept.trim().isEmpty()) {
                sql.append(" WHERE c.department = ?");
                params.add(filterDept);
                whereAdded = true;
            }
            
            // Add startDate filter if provided
            if (startDate != null && !startDate.trim().isEmpty()) {
                sql.append(whereAdded ? " AND" : " WHERE").append(" c.submission_date >= ?");
                params.add(startDate + " 00:00:00"); // start of the day
                whereAdded = true;
            }
            
            // Add endDate filter if provided
            if (endDate != null && !endDate.trim().isEmpty()) {
                sql.append(whereAdded ? " AND" : " WHERE").append(" c.submission_date <= ?");
                params.add(endDate + " 23:59:59"); // end of the day
            }
            
            PreparedStatement pst = con.prepareStatement(sql.toString());
            // Set parameters in PreparedStatement
            for (int i = 0; i < params.size(); i++) {
                pst.setString(i + 1, params.get(i).toString());
            }
            
            ResultSet rs = pst.executeQuery();
            while (rs.next()) {
                Complaint comp = new Complaint();
                comp.setComplaintId(rs.getInt("complaint_id"));
                comp.setStudentName(rs.getString("student_name"));
                comp.setEmail(rs.getString("email"));
                comp.setDepartment(rs.getString("department"));
                comp.setComplaintText(rs.getString("complaint_text"));
                comp.setStatus(rs.getString("status"));
                comp.setImagePath(rs.getString("image_path"));
                comp.setSubmissionDate(rs.getTimestamp("submission_date"));
                complaints.add(comp);
            }
            rs.close();
            pst.close();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        
        // Pass the complaints list to JSP
        request.setAttribute("complaints", complaints);
        RequestDispatcher dispatcher = request.getRequestDispatcher("admin_dashboard.jsp");
        dispatcher.forward(request, response);
    }
}
