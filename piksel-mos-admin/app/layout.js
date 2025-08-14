import "./globals.css"; // Asumsi ada file CSS dasar

export const metadata = {
  title: "Piksel Mos Admin",
  description: "Dashboard untuk mengelola konten Piksel Mos",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
