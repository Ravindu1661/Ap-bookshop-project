package com.redupahana.controller;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.redupahana.model.Customer;

@WebServlet("/customerPortal")
public class CustomerPortalController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if customer is logged in
        HttpSession session = request.getSession();
        Customer loggedCustomer = (Customer) session.getAttribute("loggedCustomer");
        String loginType = (String) session.getAttribute("loginType");
        
        if (loggedCustomer == null || !"customer".equals(loginType)) {
            response.sendRedirect("auth");
            return;
        }
        
        // Set customer info for the portal
        request.setAttribute("customer", loggedCustomer);
        
        // Forward to customer portal page
        request.getRequestDispatcher("WEB-INF/view/customer/customerPortal.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}