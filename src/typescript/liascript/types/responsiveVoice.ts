// taken from: https://responsivevoice.org/api/

type Options = {
  pitch?: number,
  rate?: number,
  volume?: number,

  onstart?: () => void,
  onend?: () => void,
  onerror?: (e: any) => void,
};


type Replacement = {
  searchvalue: string,
  newvalue: string,
  collectionvoices?: string | string[],
  systemvoices?: string | string[]
}


declare global {
  interface Window {
    responsiveVoice: {
      speak: (_text: string, _voice?: string, _cb?: Options) => void;
      cancel: () => void;
      voiceSupport: () => boolean;
      getVoices: () => string[];
      setDefaultVoice: (_: string) => void;
      setDefaultRate: (_: number) => void;
      isPlaying: () => boolean;
      pause: () => void;
      resume: () => void;

      setTextReplacements: (_: Replacement[]) => void;

      enableWindowClickHook: () => void;

      enableEstimationTimeout: boolean;

      init: () => void;
    }
  }
}

export { }
