import { useId } from 'react';

const BRAND = {
  pink: '#FF2D95',
  magenta: '#C01686',
  orange: '#FF6A2C',
  text: '#0A0A0F',
};

export interface ZMarkProps {
  size?: number;
  gradient?: boolean;
  color?: string;
  stroke?: number;
}

/** Knotted-arrow Zuvaro mark (Figma / app brand). */
export function ZMark({
  size = 64,
  gradient = false,
  color = BRAND.text,
  stroke = 7,
}: ZMarkProps) {
  const uid = useId();
  const gid = `zg${uid}`;
  const mid = `zm${uid}`;
  const pillX = 12;
  const pillY = 38;
  const pillW = 76;
  const pillH = 24;
  const pillR = 12;
  const strokeProps = {
    stroke: gradient ? `url(#${gid})` : color,
    strokeWidth: stroke,
    strokeLinecap: 'round' as const,
    strokeLinejoin: 'round' as const,
    fill: 'none',
  };

  return (
    <svg width={size} height={size} viewBox="0 0 100 100" fill="none" aria-hidden="true">
      <defs>
        <linearGradient id={gid} x1="0" y1="100%" x2="100%" y2="0">
          <stop offset="0%" stopColor={BRAND.magenta} />
          <stop offset="55%" stopColor={BRAND.pink} />
          <stop offset="100%" stopColor={BRAND.orange} />
        </linearGradient>
        <mask id={mid} maskUnits="userSpaceOnUse">
          <rect width="100" height="100" fill="white" />
          <circle cx="62" cy="38" r={stroke * 1.4} fill="black" />
        </mask>
      </defs>
      <g mask={`url(#${mid})`}>
        <rect
          x={pillX}
          y={pillY}
          width={pillW}
          height={pillH}
          rx={pillR}
          transform="rotate(-45 50 50)"
          {...strokeProps}
        />
      </g>
      <g>
        <rect
          x={pillX}
          y={pillY}
          width={pillW}
          height={pillH}
          rx={pillR}
          transform="rotate(45 50 50)"
          {...strokeProps}
        />
        <path d="M76 14 L86 14 L86 24" {...strokeProps} />
      </g>
    </svg>
  );
}

export interface ZuvaroLockupProps {
  markSize?: number;
  wordSize?: number;
  uppercase?: boolean;
  className?: string;
}

/** Mark + wordmark lockup used in app chrome. */
export function ZuvaroLockup({
  markSize = 40,
  wordSize = 28,
  uppercase = false,
  className = '',
}: ZuvaroLockupProps) {
  const label = uppercase ? 'ZUVARO' : 'zuvaro';
  return (
    <div className={`inline-flex items-center gap-2.5 ${className}`}>
      <ZMark size={markSize} />
      <span
        className="font-sora font-extrabold tracking-[-0.04em] text-[#0A0A0F]"
        style={{ fontSize: wordSize }}
      >
        {label}
      </span>
    </div>
  );
}
