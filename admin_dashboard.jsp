<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="css/styles.css">
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script>
        function confirmResolve() {
            return confirm("Are you sure you want to mark this complaint as resolved?");
        }
    </script>
    <style>
        .container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 20px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0px 8px 20px rgba(0, 0, 0, 0.1);
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header h2 { color: #2c3e50; }
        .logout-link {
            font-size: 14px;
            color: #e74c3c;
            text-decoration: none;
            font-weight: bold;
            border: 1px solid #e74c3c;
            padding: 6px 12px;
            border-radius: 4px;
            transition: background 0.3s ease;
        }
        .logout-link:hover { background: #e74c3c; color: #fff; }
        .dashboard-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            font-size: 16px;
        }
        .dashboard-table th, .dashboard-table td {
            padding: 12px;
            border: 1px solid #e1e1e1;
            text-align: left;
        }
        .dashboard-table th { background-color: #f0f8ff; color: #333; }
        .dashboard-table tr:nth-child(even) { background-color: #fafafa; }
        .dashboard-table tr:hover { background-color: #f1f7fb; }
        .action-btn {
            background: linear-gradient(45deg, #6cc1ff, #3a8ee6);
            border: none;
            color: white;
            padding: 8px 12px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease;
            font-weight: 600;
        }
        .action-btn:hover { background: linear-gradient(45deg, #3a8ee6, #2a6dbf); }
        .view-link { color: #3a8ee6; text-decoration: none; }
        .view-link:hover { text-decoration: underline; }
        .status-resolved { color: green; font-weight: bold; }
        .status-pending { color: orange; font-weight: bold; }
        .filter-form { margin-bottom: 20px; display: flex; flex-wrap: wrap; align-items: center; }
        .filter-form label { font-weight: 600; margin-right: 10px; color: #34495e; }
        .filter-form select, .filter-form input[type="date"] {
            padding: 8px 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            margin-right: 10px;
            background: #f8f9fa;
        }
        .filter-form button { padding: 8px 16px; background: #3a8ee6; border: none; color: #fff; border-radius: 5px; font-weight: 600; }
        .filter-form button:hover { background: #2a6dbf; }
        .message { font-weight: bold; padding: 10px; border-radius: 5px; margin-bottom: 15px; }
        .message.success { background-color: #d4edda; color: #155724; }
        .message.error { background-color: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Complaints Dashboard</h2>
            <a class="logout-link" href="LogoutServlet">Logout</a>
        </div>

        <c:if test="${not empty param.success}">
            <p class="message success">✔ ${param.success}</p>
        </c:if>
        <c:if test="${not empty param.error}">
            <p class="message error">❌ ${param.error}</p>
        </c:if>

        <!-- Pie Chart for Complaint Status -->
        <div id="chart_div" style="width: 600px; height: 400px;"></div>
        
        <!-- Filter Form -->
        <form class="filter-form" action="AdminDashboardServlet" method="get">
            <label for="filterDept">Department:</label>
            <select name="filterDept" id="filterDept">
                <option value="">All</option>
                <option value="VC">VC</option>
                <option value="Admission Cell">Admission Cell</option>
                <option value="Examination Cell">Examination Cell</option>
                <option value="Accounts">Accounts</option>
                <option value="HOD">HOD</option>
            </select>
            <label for="startDate">Start Date:</label>
            <input type="date" name="startDate" id="startDate">
            <label for="endDate">End Date:</label>
            <input type="date" name="endDate" id="endDate">
            <button type="submit">Apply Filter</button>
        </form>

        <!-- Complaints Table -->
        <table class="dashboard-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Student Name</th>
                    <th>Email</th>
                    <th>Department</th>
                    <th>Complaint</th>
                    <th>Status</th>
                    <th>Submitted On</th>
                    <th>File</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="comp" items="${complaints}">
                    <tr>
                        <td>${comp.complaintId}</td>
                        <td>${comp.studentName}</td>
                        <td>${comp.email}</td>
                        <td>${comp.department}</td>
                        <td>${comp.complaintText}</td>
                        <td>
                            <c:choose>
                                <c:when test="${comp.status == 'Resolved'}">
                                    <span class="status-resolved">✔ Resolved</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-pending">⏳ Pending</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>${comp.submissionDate}</td>
                        <td>
                            <c:if test="${not empty comp.imagePath}">
                                <a class="view-link" href="${comp.imagePath}" target="_blank">View File</a>
                            </c:if>
                            <c:if test="${empty comp.imagePath}">N/A</c:if>
                        </td>
                        <td>
                            <form action="ResolveComplaintServlet" method="post" onsubmit="return confirmResolve();">
                                <input type="hidden" name="complaint_id" value="${comp.complaintId}">
                                <button type="submit" class="action-btn">Mark as Resolved</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <!-- Export to CSV Button -->
        <a href="ExportComplaintsServlet" class="action-btn">📥 Export CSV</a>
    </div>
</body>
</html>
