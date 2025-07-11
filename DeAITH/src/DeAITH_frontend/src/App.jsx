import { useState, useEffect } from 'react';
import { AuthClient } from '@dfinity/auth-client';
import { HttpAgent } from '@dfinity/agent';
import { UserData } from 'declarations/UserData';
import { RewardToken } from 'declarations/RewardToken';
import { TrainingManager } from 'declarations/TrainingManager';
import PatientDashboard from './components/PatientDashboard';
import ResearcherDashboard from './components/ResearcherDashboard';
import LandingPage from './components/LandingPage';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [authClient, setAuthClient] = useState(null);
  const [identity, setIdentity] = useState(null);
  const [principal, setPrincipal] = useState(null);
  const [userType, setUserType] = useState(null); // 'patient' or 'researcher'

  useEffect(() => {
    initAuth();
  }, []);

  async function initAuth() {
    const client = await AuthClient.create();
    setAuthClient(client);

    const isAuthenticated = await client.isAuthenticated();
    setIsAuthenticated(isAuthenticated);

    if (isAuthenticated) {
      const identity = client.getIdentity();
      setIdentity(identity);
      setPrincipal(identity.getPrincipal().toString());
    }
  }

  async function login() {
    // Always use the IC network Internet Identity for local development
    const internetIdentityUrl = "https://identity.ic0.app";

    await authClient?.login({
      identityProvider: internetIdentityUrl,
      onSuccess: async () => {
        setIsAuthenticated(true);
        const identity = authClient.getIdentity();
        setIdentity(identity);
        setPrincipal(identity.getPrincipal().toString());
        
        // Initialize user profile
        try {
          const result = await UserData.initProfile();
          console.log("Profile initialized:", result);
        } catch (error) {
          console.log("Profile might already exist:", error);
        }
      },
    });
  }

  async function logout() {
    await authClient?.logout();
    setIsAuthenticated(false);
    setIdentity(null);
    setPrincipal(null);
    setUserType(null);
  }

  function selectUserType(type) {
    setUserType(type);
  }

  if (!isAuthenticated) {
    return <LandingPage onLogin={login} />;
  }

  if (!userType) {
    return (
      <div className="user-type-selection">
        <h1>Welcome to DeAITH</h1>
        <p>Please select your role:</p>
        <div className="role-buttons">
          <button onClick={() => selectUserType('patient')} className="role-button patient">
            I'm a Patient (Data Contributor)
          </button>
          <button onClick={() => selectUserType('researcher')} className="role-button researcher">
            I'm a Researcher
          </button>
        </div>
        <button onClick={logout} className="logout-button">Logout</button>
      </div>
    );
  }

  return (
    <div className="app">
      {userType === 'patient' ? (
        <PatientDashboard 
          principal={principal} 
          onLogout={logout}
          UserData={UserData}
          RewardToken={RewardToken}
        />
      ) : (
        <ResearcherDashboard 
          principal={principal} 
          onLogout={logout}
          TrainingManager={TrainingManager}
          UserData={UserData}
          RewardToken={RewardToken}
        />
      )}
    </div>
  );
}

export default App;
