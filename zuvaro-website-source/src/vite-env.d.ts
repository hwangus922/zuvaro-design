/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_INSTALL_URL?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
