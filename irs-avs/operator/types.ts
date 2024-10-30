import { TaskType } from "./irsOperator";

export interface Task {
  taskCreatedBlock: number;
  taskType: TaskType;
  payload: string;
}

export interface SwapRequest {
  user: string;
  notionalAmount: bigint;
  fixedRate: number;
  isPayingFixed: boolean;
  duration: number;
}

export interface RateValidation {
  swapsToSettle: number[];
  proposedRate: number;
}
