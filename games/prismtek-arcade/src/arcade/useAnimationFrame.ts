import { useEffect, useRef } from "react";

export function useAnimationFrame(active: boolean, callback: (deltaMs: number, now: number) => void) {
  const callbackRef = useRef(callback);
  const frameRef = useRef<number | null>(null);
  const lastTimeRef = useRef<number | null>(null);

  callbackRef.current = callback;

  useEffect(() => {
    if (!active) {
      if (frameRef.current !== null) cancelAnimationFrame(frameRef.current);
      frameRef.current = null;
      lastTimeRef.current = null;
      return;
    }

    function tick(now: number) {
      const previous = lastTimeRef.current ?? now;
      const deltaMs = Math.min(40, now - previous);
      lastTimeRef.current = now;
      callbackRef.current(deltaMs, now);
      frameRef.current = requestAnimationFrame(tick);
    }

    frameRef.current = requestAnimationFrame(tick);
    return () => {
      if (frameRef.current !== null) cancelAnimationFrame(frameRef.current);
      frameRef.current = null;
      lastTimeRef.current = null;
    };
  }, [active]);
}
