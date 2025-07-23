import React, { useState, useEffect } from 'react';
import CryptoJS from 'crypto-js';
import PrivacyCenter from './PrivacyCenter';

function PatientDashboard({ principal, onLogout, UserData, RewardToken }) {
  const [profile, setProfile] = useState(null);
  const [balance, setBalance] = useState(0);
  const [dataCount, setDataCount] = useState(0);
  const [healthData, setHealthData] = useState('');
  const [dataType, setDataType] = useState('smartwatch');
  const [uiState, setUiState] = useState({ status: 'idle', message: '' }); // 'idle', 'loading', 'success', 'error'

  useEffect(() => {
    loadUserData();
    
    // Set up polling for balance updates every 5 seconds
    const interval = setInterval(() => {
      loadUserData();
    }, 5000);
    
    // Cleanup interval on component unmount
    return () => clearInterval(interval);
  }, []);

  async function loadUserData() {
    try {
      // Get user profile
      const userProfile = await UserData.getProfile(principal);
      if (userProfile && userProfile.length > 0) {
        setProfile(userProfile[0]);
        setDataCount(Number(userProfile[0].dataCount));
      }

      // Get token balance
      const tokenBalance = await RewardToken.balanceOf(principal);
      setBalance(Number(tokenBalance) / 100000000); // Convert from smallest unit
    } catch (error) {
      console.error("Error loading user data:", error);
    }
  }

  async function handleSubmitData() {
    if (!healthData.trim()) {
      setUiState({ status: 'error', message: 'Please enter some health data' });
      return;
    }

    setUiState({ status: 'loading', message: 'Mengenkripsi & Menyimpan...' });

    try {
      // Encrypt data on client side (in production, use a more secure method)
      const encryptionKey = 'DeAITH-demo-key-' + principal.toString();
      const encryptedData = CryptoJS.AES.encrypt(healthData, encryptionKey).toString();

      // Call the updated function
      const result = await UserData.storeHealthData(encryptedData, dataType);
      
      // 'result.ok' now contains the UserProfile object
      if ('ok' in result) {
        setUiState({ status: 'success', message: 'Data berhasil disimpan!' });
        setHealthData('');
        
        // DIRECTLY UPDATE STATE FROM THE RECEIVED RESULT
        const updatedProfile = result.ok;
        setProfile(updatedProfile);
        setDataCount(Number(updatedProfile.dataCount));
      } else {
        setUiState({ status: 'error', message: 'Error: ' + result.err });
      }
    } catch (error) {
      setUiState({ status: 'error', message: 'Error: ' + error.message });
    }
  }

  return (
    <div className="dashboard patient-dashboard">
      <header className="dashboard-header">
        <h1>Selamat Datang!</h1>
        <div className="header-info">
          <span className="principal">Principal ID: {principal.slice(0, 10)}...</span>
          <button onClick={onLogout} className="logout-button">Logout</button>
        </div>
      </header>

      <div className="dashboard-content">
        <div className="info-cards">
          <div className="info-card">
            <h3>Saldo DeAITH Token Anda</h3>
            <p className="big-number">{balance.toFixed(2)} DEAITH</p>
          </div>
          <div className="info-card">
            <h3>Jumlah Data Terkontribusi</h3>
            <p className="big-number">{dataCount}</p>
          </div>
        </div>

        <div className="upload-section">
          <h2>Unggah Data Kesehatan Baru</h2>
          <div className="form-group">
            <label>Tipe Data:</label>
            <select 
              value={dataType} 
              onChange={(e) => setDataType(e.target.value)}
              className="data-type-select"
            >
              <option value="smartwatch">Smartwatch Data</option>
              <option value="lab_results">Lab Results</option>
              <option value="medical_records">Medical Records</option>
              <option value="fitness_data">Fitness Data</option>
            </select>
          </div>
          <div className="form-group">
            <label>Data Kesehatan:</label>
            <textarea
              value={healthData}
              onChange={(e) => setHealthData(e.target.value)}
              placeholder="Masukkan data kesehatan Anda di sini (contoh: heart rate, blood pressure, etc.)"
              rows="6"
              className="health-data-input"
            />
          </div>
          <button 
            onClick={handleSubmitData} 
            disabled={uiState.status === 'loading'}
            className="submit-button"
          >
            {uiState.status === 'loading' ? 'Mengenkripsi & Menyimpan...' : 'Enkripsi & Simpan On-Chain'}
          </button>
          {uiState.message && (
            <p className={`message ${uiState.status === 'error' ? 'error' : uiState.status === 'success' ? 'success' : ''}`}>
              {uiState.message}
            </p>
          )}
        </div>

        <div className="privacy-section">
          <PrivacyCenter UserData={UserData} />
        </div>
      </div>
    </div>
  );
}

export default PatientDashboard;
