declare global {
  interface Window {
    API?: SCORM
  }
}

export type SCORM = {
  LMSInitialize: (_: string) => bool
  LMSFinish: (_: string) => bool
  LMSGetValue: (_: CMIElement) => string
  LMSSetValue: (_: CMIElement, value: string) => string
  LMSCommit: () => void
  LMSGetLastError: () => string | null
  LMSGetErrorString: (_: CMIErrorCode) => string
  LMSGetDiagnostic: (_: CMIErrorCode) => string
}

export type CMIElement = string | null

export type CMIErrorCode = string | null
