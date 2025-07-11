import React from 'react';

function LandingPage({ onLogin }) {
  return (
    <div className="landing-page">
      <div className="landing-content">
        <h1 className="landing-title">DeAITH</h1>
        <h2 className="landing-subtitle">Decentralized AI for Health</h2>
        <p className="landing-description">
          Securely contribute your health data to advance AI research while maintaining 
          complete privacy and earning rewards for your contributions.
        </p>
        
        <div className="features">
          <div className="feature">
            <h3>🔒 Complete Privacy</h3>
            <p>Your data is encrypted on your device using vetKeys technology</p>
          </div>
          <div className="feature">
            <h3>💰 Earn Rewards</h3>
            <p>Get DeAITH tokens every time your data is used for AI training</p>
          </div>
          <div className="feature">
            <h3>🤖 Advance Research</h3>
            <p>Help train AI models that can improve healthcare for everyone</p>
          </div>
        </div>
        
        <button onClick={onLogin} className="login-button">
          Login / Start
        </button>
      </div>
    </div>
  );
}

export default LandingPage;
