'use client';

import { useEffect, useState } from 'react';
import { supabase } from 'lib/supabaseClient'; // Menggunakan alamat pintas

export default function DashboardPage() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function checkUser() {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) {
        window.location.href = '/';
      } else {
        setUser(session.user);
        setLoading(false);
      }
    }
    checkUser();
  }, []);

  async function handleLogout() {
    await supabase.auth.signOut();
    window.location.href = '/';
  }

  if (loading) {
    return <div>Memuat...</div>;
  }

  return (
    <div style={{ padding: '50px' }}>
      <h1>Admin Dashboard</h1>
      <p>Selamat datang, {user?.email}</p>
      <button onClick={handleLogout}>Logout</button>
      <hr style={{ margin: '20px 0' }}/>
      <h2>Manajemen Konten</h2>
      <p>Area untuk mengelola postingan akan ada di sini.</p>
    </div>
  );
}
