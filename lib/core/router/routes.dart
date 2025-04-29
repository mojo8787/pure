/// App route paths
class Routes {
  // Auth
  static const login = '/login';
  static const signup = '/signup';
  static const verification = '/verification';
  static const authCallback = '/auth/callback';
  
  // Main Navigation
  static const dashboard = '/dashboard';
  
  // Subscription Management
  static const subscriptions = '/subscriptions';
  static const addSubscription = '/subscriptions/new';
  static const subscriptionDetail = '/subscriptions/:id';
  
  // Onboarding Flow
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  
  // Subscription Flow
  static const termsPlan = '/terms-plan';
  static const contractSign = '/contract-sign';
  static const payment = '/payment';
  static const schedule = '/schedule';
  static const confirmation = '/confirmation';
  
  // Customer Dashboard
  static const invoiceDetail = '/invoice';
  static const supportTicket = '/support';
  
  // Todo Feature
  static const todos = '/todos';
  static const todoDetail = '/todos/:id';
  
  // Technician Flow
  static const techSchedule = '/tech/schedule';
  static const jobDetail = '/tech/job';
  static const signature = '/tech/signature';
  static const tickets = '/tech/tickets';
  
  // Admin Flow (Web)
  static const adminDashboard = '/admin';
  static const adminCustomers = '/admin/customers';
  static const adminSubscriptions = '/admin/subscriptions';
  static const adminTechnicians = '/admin/technicians';
  static const adminAppointments = '/admin/appointments';
  static const adminTickets = '/admin/tickets';
  static const adminInvoices = '/admin/invoices';
  static const adminSettings = '/admin/settings';
  
  // New route
  static const String scheduleVisit = '/schedule-visit';
} 