import { env } from '../../config/env';
import { SERVICE_PATHS, SOAP_ACTIONS } from './cardwalla.constants';
import { buildProductsEnvelope } from './cardwalla.envelopes';
import { postSoap } from './cardwalla.http';
import { parseProducts } from './cardwalla.parser';
import { getSessionToken } from './cardwalla.session';

export const fetchProducts = async () => {
  const token = await getSessionToken();
  const xml = await postSoap(
    `${env.CARDWALLA_BASE_URL}${SERVICE_PATHS.agent}`,
    SOAP_ACTIONS.products,
    buildProductsEnvelope(token),
  );
  return parseProducts(xml);
};
