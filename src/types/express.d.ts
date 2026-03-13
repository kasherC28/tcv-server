import { Role, UserStatus, Gender } from '../common/enums';

declare global {
  namespace Express {
    interface UserShape {
      id: number;
      name: string;
      f_name: string;
      email: string;
      password: string;
      role: Role;
      status: UserStatus;
      contact: string;
      dob: string;
      address?: string | null;
      city?: string | null;
      country?: string | null;
      gender: Gender;
      recorded: number;
      modified: number;
    }

    interface Request {
      user?: UserShape;
    }
  }
}

export {};
