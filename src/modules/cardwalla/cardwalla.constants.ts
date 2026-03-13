export const SOAP_ACTIONS = {
  login: 'http://localhost:60032/service/IAgentService/AgentLogin',
  products: 'http://localhost:60032/service/IAgentService/GetAgentProducts',
  purchase: 'http://localhost:60032/service/IPurchaseService/MakeProductPurchase',
  transactionInfo: 'http://localhost:60032/service/IReportsService/GetTransactionInfo',
} as const;

export const SERVICE_PATHS = {
  agent: '/AgentService.svc/AgentService',
  purchase: '/PurchaseService.svc/PurchaseService',
  reports: '/ReportsService.svc/ReportsService',
} as const;
