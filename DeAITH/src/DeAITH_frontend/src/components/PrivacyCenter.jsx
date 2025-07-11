import React, { useState } from 'react';

function PrivacyCenter({ UserData }) {
  const [status, setStatus] = useState('Belum ada aksi');
  const [simulatedKey, setSimulatedKey] = useState('');

  // Fungsi ini akan dipanggil saat tombol ditekan
  const handleGetKey = async () => {
    setStatus('Memanggil canister untuk simulasi permintaan kunci...');
    try {
      // Panggil fungsi placeholder di backend
      // Untuk tujuan demo, kita bisa pakai principal canister itu sendiri sebagai dummy researcherId
      const dummyResearcherId = "aaaaa-aa"; // Principal anonim
      const result = await UserData.getKeyForResearcher(dummyResearcherId);
      
      setSimulatedKey(result);
      setStatus('Simulasi berhasil. Kunci terenkripsi dummy diterima.');
    } catch (error) {
      console.error("Error saat simulasi:", error);
      setStatus('Gagal melakukan simulasi.');
    }
  };

  return (
    <div className="privacy-center">
      <h3>Pusat Privasi & Kedaulatan Data</h3>
      <p>
        Data Anda dienkripsi <strong>sebelum</strong> diunggah ke blockchain. Dengan teknologi canggih <strong>vetKeys</strong> dari Internet Computer, hanya Anda yang bisa memberikan izin kepada pihak ketiga (seperti peneliti AI) untuk mendapatkan kunci dekripsi sementara, tanpa platform ini atau siapapun bisa melihat data asli Anda.
      </p>
      <button onClick={handleGetKey} className="privacy-action-btn">
        Simulasikan Permintaan Akses dari Peneliti
      </button>
      
      <div className="status-box">
        <p><strong>Status Simulasi:</strong> {status}</p>
        {simulatedKey && (
          <p><strong>Kunci Dummy Diterima:</strong> <code className="simulated-key">{simulatedKey}</code></p>
        )}
      </div>
    </div>
  );
}

export default PrivacyCenter;
