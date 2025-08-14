// app/dashboard/page.js

'use client'; // Komponen interaktif

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabaseClient'; // Sesuaikan path jika perlu

export default function DashboardPage() {
  const [user, setUser] = useState(null);
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Fungsi untuk memeriksa sesi login dan mengambil data
    async function checkUserAndFetchPosts() {
      // 1. Periksa apakah ada pengguna yang login
      const { data: { session } } = await supabase.auth.getSession();
      
      if (!session) {
        // Jika tidak ada sesi, paksa kembali ke halaman login
        window.location.href = '/';
      } else {
        setUser(session.user);

        // 2. Ambil semua data dari tabel 'posts'
        const { data: postsData, error } = await supabase
          .from('posts')
          .select('*')
          .order('created_at', { ascending: false });

        if (postsData) {
          setPosts(postsData);
        }
        setLoading(false);
      }
    }

    checkUserAndFetchPosts();
  }, []); // [] berarti efek ini hanya berjalan sekali saat halaman dimuat

  // Fungsi untuk logout
  async function handleLogout() {
    await supabase.auth.signOut();
    window.location.href = '/';
  }

  // Tampilkan loading jika data belum siap
  if (loading) {
    return <div>Loading...</div>;
  }

  // Tampilan utama dashboard
  return (
    <div>
      <h1>Admin Dashboard</h1>
      <p>Selamat datang, {user?.email}</p>
      <button onClick={handleLogout}>Logout</button>
      
      <hr />

      <h2>Daftar Postingan</h2>
      {posts.length > 0 ? (
        <table border="1" style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr>
              <th>Judul</th>
              <th>Caption</th>
              <th>Tanggal Dibuat</th>
            </tr>
          </thead>
          <tbody>
            {posts.map((post) => (
              <tr key={post.id}>
                <td>{post.title}</td>
                <td>{post.caption}</td>
                <td>{new Date(post.created_at).toLocaleString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : (
        <p>Belum ada postingan.</p>
      )}

      {/* Anda bisa menambahkan tombol "Tambah Postingan Baru" di sini nanti */}

    </div>
  );
}