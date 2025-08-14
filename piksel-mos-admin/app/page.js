'use client';

import { useState } from 'react';
import { supabase } from 'lib/supabaseClient'; // Menggunakan alamat pintas

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  async function handleLogin() {
    setLoading(true);
    setError(null);
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email: email,
        password: password,
      });
      if (error) throw error;
      window.location.href = '/dashboard';
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div style={{ padding: '50px', maxWidth: '400px', margin: 'auto' }}>
      <h1>Admin Login</h1>
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        style={{ width: '100%', padding: '8px', marginBottom: '10px' }}
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        style={{ width: '100%', padding: '8px', marginBottom: '20px' }}
      />
      <button onClick={handleLogin} disabled={loading} style={{ width: '100%', padding: '10px' }}>
        {loading ? 'Loading...' : 'Masuk'}
      </button>
      {error && <p style={{ color: 'red', marginTop: '10px' }}>{error}</p>}
    </div>
  );
}
