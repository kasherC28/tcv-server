import { env } from '../../config/env';
import { SERVICE_PATHS, SOAP_ACTIONS } from './cardwalla.constants';
import { buildLoginEnvelope } from './cardwalla.envelopes';
import { postSoap } from './cardwalla.http';
import { parseLogin } from './cardwalla.parser';
import { CardwallaSession } from './cardwalla.types';

let cache: CardwallaSession | null = null;

const login = async () => {
  const xml = await postSoap(
    `${env.CARDWALLA_BASE_URL}${SERVICE_PATHS.agent}`,
    SOAP_ACTIONS.login,
    buildLoginEnvelope(env.CARDWALLA_TERMINAL_ID, env.CARDWALLA_USERNAME, env.CARDWALLA_PASSWORD),
  );
  cache = {
    token: parseLogin(xml),
    expiresAt: Date.now() + env.CARDWALLA_SESSION_TTL_MINUTES * 60 * 1000,
  };
  return cache.token;
};

export const getSessionToken = async () => {
  if (cache && cache.expiresAt > Date.now()) return cache.token;
  return login();
};
