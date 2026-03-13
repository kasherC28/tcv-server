import { buildTimestamp, buildTransactionId } from './cardwalla.helpers';

const baseEnvelope = (body: string) =>
  `<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:typ="http://soap.api.novatti.com/types">
<soap:Header/><soap:Body>${body}</soap:Body></soap:Envelope>`;

export const buildLoginEnvelope = (terminalId: string, username: string, password: string) =>
  baseEnvelope(`<typ:SoapAgentLoginRequest><header><authentication><terminalId>${terminalId}</terminalId><userName>${username}</userName><password>${password}</password></authentication><agentTransactionId>${buildTransactionId()}</agentTransactionId><agentTimeStamp>${buildTimestamp()}</agentTimeStamp></header></typ:SoapAgentLoginRequest>`);

export const buildProductsEnvelope = (sessionToken: string) =>
  baseEnvelope(`<typ:SoapAgentProductsRequest><header><authentication><sessionToken>${sessionToken}</sessionToken></authentication><agentTransactionId>${buildTransactionId()}</agentTransactionId><agentTimeStamp>${buildTimestamp()}</agentTimeStamp></header></typ:SoapAgentProductsRequest>`);

export const buildPurchaseEnvelope = (
  sessionToken: string,
  productCode: string,
  email: string,
  msisdn?: string,
) =>
  baseEnvelope(`<typ:SoapProductPurchaseRequest><header><authentication><sessionToken>${sessionToken}</sessionToken></authentication><agentTransactionId>${buildTransactionId()}</agentTransactionId><agentTimeStamp>${buildTimestamp()}</agentTimeStamp></header><email>${email}</email>${msisdn ? `<msisdn>${msisdn}</msisdn>` : ''}<productCode>${productCode}</productCode></typ:SoapProductPurchaseRequest>`);
