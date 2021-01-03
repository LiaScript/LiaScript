export as namespace Lia;

export enum ErrType {
  error = 'error',
  warning = 'warning',
  info = 'info'
}

export type ErrMessage = {
  row: number,
  column?: number,
  text: string,
  type: Lia.ErrType
}
