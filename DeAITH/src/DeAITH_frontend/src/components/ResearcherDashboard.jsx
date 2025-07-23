import React, { useState, useEffect } from 'react';

function ResearcherDashboard({ principal, onLogout, TrainingManager, UserData, RewardToken }) {
  const [jobs, setJobs] = useState([]);
  const [jobName, setJobName] = useState('');
  const [jobDescription, setJobDescription] = useState('');
  const [uiState, setUiState] = useState({ status: 'idle', message: '' }); // 'idle', 'loading', 'success', 'error'

  useEffect(() => {
    loadJobs();
  }, []);

  async function loadJobs() {
    try {
      const researcherJobs = await TrainingManager.getResearcherJobs(principal);
      setJobs(researcherJobs);
    } catch (error) {
      console.error("Error loading jobs:", error);
    }
  }

  async function handleSubmitJob() {
    if (!jobName.trim()) {
      setUiState({ status: 'error', message: 'Please enter a job name' });
      return;
    }

    setUiState({ status: 'loading', message: `Submitting job "${jobName}" to the network...` });

    try {
      // Using the new submitTrainingJob function that includes timer
      const result = await TrainingManager.submitTrainingJob(jobName);
      if ('ok' in result) {
        setUiState({
          status: 'success',
          message: `Job "${jobName}" successfully submitted! Training will start in 30 seconds and rewards will be distributed automatically.`
        });
        setJobName('');
        setJobDescription('');
        
        // Reload jobs after a delay to show the new job
        setTimeout(() => loadJobs(), 2000);
      } else {
        setUiState({ status: 'error', message: 'Error: ' + result.err });
      }
    } catch (error) {
      setUiState({ status: 'error', message: 'Error: ' + error.message });
    }
  }

  function getStatusBadge(status) {
    const statusMap = {
      'Pending': 'pending',
      'Running': 'running',
      'Completed': 'completed',
      'Failed': 'failed'
    };
    
    const statusText = Object.keys(status)[0];
    return <span className={`status-badge ${statusMap[statusText]}`}>{statusText}</span>;
  }

  return (
    <div className="dashboard researcher-dashboard">
      <header className="dashboard-header">
        <h1>Researcher Dashboard</h1>
        <div className="header-info">
          <span className="principal">Principal ID: {principal.slice(0, 10)}...</span>
          <button onClick={onLogout} className="logout-button">Logout</button>
        </div>
      </header>

      <div className="dashboard-content">
        <div className="submit-job-section">
          <h2>Submit Training Job Baru</h2>
          <div className="form-group">
            <label>Nama Job:</label>
            <input
              type="text"
              value={jobName}
              onChange={(e) => setJobName(e.target.value)}
              placeholder="e.g., Heart Disease Prediction Model"
              className="job-input"
            />
          </div>
          <div className="form-group">
            <label>Deskripsi:</label>
            <textarea
              value={jobDescription}
              onChange={(e) => setJobDescription(e.target.value)}
              placeholder="Describe your AI training job and data requirements..."
              rows="4"
              className="job-description"
            />
          </div>
          <button 
            onClick={handleSubmitJob} 
            disabled={uiState.status === 'loading'}
            className="submit-button"
          >
            {uiState.status === 'loading' ? 'Submitting...' : 'Submit Job'}
          </button>
          {uiState.message && (
            <p className={`message ${uiState.status === 'error' ? 'error' : uiState.status === 'success' ? 'success' : ''}`}>
              {uiState.message}
            </p>
          )}
        </div>

        <div className="jobs-history">
          <h2>Riwayat Training Jobs</h2>
          {jobs.length === 0 ? (
            <p className="no-jobs">No training jobs yet. Submit your first job above!</p>
          ) : (
            <table className="jobs-table">
              <thead>
                <tr>
                  <th>Nama Job</th>
                  <th>Deskripsi</th>
                  <th>Status</th>
                  <th>Contributors</th>
                </tr>
              </thead>
              <tbody>
                {jobs.map((job) => (
                  <tr key={job.id}>
                    <td>{job.name}</td>
                    <td>{job.description}</td>
                    <td>{getStatusBadge(job.status)}</td>
                    <td>{job.dataContributors.length}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}

export default ResearcherDashboard;
