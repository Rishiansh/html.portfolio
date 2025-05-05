<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    if (session == null || session.getAttribute("email") == null) {
        response.sendRedirect("login.jsp?error=Please+login+first");
        return;
    }
    String email = (String) session.getAttribute("email");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student Dashboard</title>
    <link rel="stylesheet" href="css/styles.css">
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f3f7fa;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            background: #ffffff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
            width: 80%;
            max-width: 900px;
            text-align: center;
        }
        h2 {
            color: #4a90e2;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0px 2px 8px rgba(0, 0, 0, 0.1);
        }
        th, td {
            padding: 12px;
            text-align: center;
            border-bottom: 1px solid #e0e0e0;
        }
        th {
            background-color: #4a90e2;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #e8f0fe;
        }
        a {
            text-decoration: none;
            color: #4a90e2;
            font-weight: bold;
            transition: 0.3s;
        }
        a:hover {
            color: #356ac3;
        }
        .button {
            display: inline-block;
            padding: 10px 20px;
            margin-top: 10px;
            background: #4a90e2;
            color: white;
            border-radius: 6px;
            text-decoration: none;
            transition: 0.3s;
        }
        .button:hover {
            background: #356ac3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Your Complaints</h2>
        <table>
            <tr>
                <th>ID</th>
                <th>Department</th>
                <th>Complaint</th>
                <th>Status</th>
                <th>File</th>
            </tr>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/university_complaints", "root", "sathi");
                    String sql = "SELECT c.complaint_id, c.department, c.complaint_text, c.status, c.image_path " +
                                 "FROM complaints c JOIN users u ON c.user_id = u.id " +
                                 "WHERE u.email = ?";
                    PreparedStatement pst = con.prepareStatement(sql);
                    pst.setString(1, email);
                    ResultSet rs = pst.executeQuery();
                    while (rs.next()) {
            %>
            <tr>
                <td><%= rs.getInt("complaint_id") %></td>
                <td><%= rs.getString("department") %></td>
                <td><%= rs.getString("complaint_text") %></td>
                <td><%= rs.getString("status") %></td>
                <td>
                    <%
                        String filePath = rs.getString("image_path");
                        if (filePath != null && !filePath.trim().isEmpty()) {
                    %>
                        <a href="<%= filePath %>" target="_blank">View File</a>
                    <%
                        } else {
                    %>
                        N/A
                    <%
                        }
                    %>
                </td>
            </tr>
            <%
                    }
                    rs.close();
                    pst.close();
                    con.close();
                } catch (Exception e) {
                    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                }
            %>
        </table>
        <br>
        <a href="student_complaint.jsp" class="button">Submit a New Complaint</a>
        <br><br>
        <a href="LogoutServlet" class="button">Logout</a>
    </div>
</body>
</html>
