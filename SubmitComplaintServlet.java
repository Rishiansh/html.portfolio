import java.io.*;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/SubmitComplaintServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,   // 2MB
    maxFileSize = 1024 * 1024 * 10,          // 10MB
    maxRequestSize = 1024 * 1024 * 50         // 50MB
)
public class SubmitComplaintServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIR = "complaint_images";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Retrieve form fields
        String name         = request.getParameter("name");
        String email        = request.getParameter("email");
        String department   = request.getParameter("department");
        String complaintText= request.getParameter("complaint");
        
        // Retrieve file part (if provided)
        Part filePart = request.getPart("file");
        String fileName = null;
        if (filePart != null && filePart.getSize() > 0) {
            fileName = filePart.getSubmittedFileName();
        }
        
        // Build upload path (ensure directory exists)
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File fileSaveDir = new File(uploadPath);
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdirs();
        }
        
        // Save file if exists
        String filePath = null;
        if (fileName != null && !fileName.isEmpty()) {
            filePath = UPLOAD_DIR + "/" + fileName; // store relative path for retrieval
            filePart.write(uploadPath + File.separator + fileName);
        }
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/university_complaints", "root", "sathi");
            
            // Insert complaint using user_id from users table
            String sql = "INSERT INTO complaints (user_id, department, complaint_text, image_path, status) " +
                         "VALUES ((SELECT id FROM users WHERE email = ?), ?, ?, ?, 'Pending')";
            PreparedStatement pst = con.prepareStatement(sql);
            pst.setString(1, email);
            pst.setString(2, department);
            pst.setString(3, complaintText);
            pst.setString(4, filePath); // can be null if no file uploaded
            pst.executeUpdate();
            
            pst.close();
            con.close();
            
            response.sendRedirect("success.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}
