// app/page.js

'use client'; // Baris ini penting, memberitahu Next.js bahwa ini adalah komponen interaktif

import { useState } from 'react';
import { supabase } from '../lib/supabaseClient'; // Impor koneksi supabase

export default function LoginPage() {
  // State untuk menyimpan input dari pengguna (seperti TextEditingController di Flutter)
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);

  // ================================================================
  // DI SINILAH ANDA MENEMPATKAN FUNGSI handleLogin ANDA
  // ================================================================
  async function handleLogin() {
    setError(null); // Reset pesan error setiap kali tombol ditekan
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email: email,
        password: password,
      });

      if (error) {
        throw error; // Lempar error jika Supabase mengembalikannya
      }

      // Jika sukses, arahkan ke dashboard
      window.location.href = '/dashboard'; // Anda akan membuat halaman ini nanti

    } catch (error) {
      // Jika terjadi error, simpan pesannya untuk ditampilkan
      setError(error.message);
    }
  }

  // Ini adalah bagian UI (seperti widget build() di Flutter)
  return (
    <div>
      <h1>Admin Login</h1>
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <br />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <br />
      <button onClick={handleLogin}>
        Masuk
      </button>

      {/* Tampilkan pesan error jika ada */}
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </div>
  );
}