# 🧠 DeAITH: Decentralized AI for Health

[![WCHL25 Hackathon](https://img.shields.io/badge/WCHL-2025-blue)](https://www.google.com/search?q=WCHL+2025+Hackathon)
[![ICP](https://img.shields.io/badge/Powered%20by-Internet%20Computer-black?logo=dfinity)](https://internetcomputer.org)
[![Language](https://img.shields.io/badge/Language-Motoko-orange)](https://internetcomputer.org/docs/motoko/home)
[![Frontend](https://img.shields.io/badge/Frontend-React-blue?logo=react)](https://react.dev/)

**DeAITH is a decentralized data union platform that allows individuals to securely and anonymously contribute their health data for AI research and earn fair rewards.**

---

## 📖 Table of Contents

1.  [**Introduction: The Problem & Our Solution**](#1-introduction-the-problem--our-solution)
2.  [**Live Demo & Key Features**](#2-live-demo--key-features)
3.  [**Application Architecture**](#3-application-architecture)
4.  [**ICP Features Used**](#4-icp-features-used)
5.  [**Technology Stack**](#5-technology-stack)
6.  [**Local Development (Build & Deployment)**](#6-local-development-build--deployment)
7.  [**Mainnet Canister IDs**](#7-mainnet-canister-ids)
8.  [**Challenges Faced**](#8-challenges-faced)
9.  [**Future Plans (Roadmap)**](#9-future-plans-roadmap)
10. [**Our Team**](#10-our-team)

---

## **1. Introduction: The Problem & Our Solution**

**The Problem:** Health data is one of the most valuable assets in the age of AI, yet it is currently centralized, inaccessible, and often used without fair consent or compensation for its owners—the patients. Patients lack sovereignty over their data, and AI researchers struggle to acquire high-quality datasets for innovation.

**Our Solution (DeAITH):** DeAITH flips this model on its head. We are building a "data union" on the Internet Computer where:
* **Patients are in full control:** Data is encrypted on the user's device *before* being uploaded. With an architecture designed for `vetKeys`, only the patient can grant access.
* **Fair and automated rewards:** Every time the data pool is used to train an AI model, a smart contract automatically distributes `DTH` (DeAITH Token) to all data contributors.
* **Privacy is paramount:** Our platform never sees the patients' raw data, creating a secure and trustworthy environment for AI innovation.

## **2. Live Demo & Key Features**

* **Live dApp:** `[LINK_TO_YOUR_MAINNET_FRONTEND_DAPP_HERE]`
* **Video Demo:** `[LINK_TO_YOUR_YOUTUBE_DEMO_VIDEO_HERE]`

### Key Features:

* **Secure, Decentralized Login:** Utilizes **Internet Identity** for secure, passwordless user authentication.
* **Client-Side Encryption:** Health data is encrypted in the user's browser before it's sent to the blockchain, ensuring maximum privacy.
* **On-Chain Storage:** Encrypted data is stored permanently and securely inside ICP canisters.
* **AI Training Job Simulation:** AI Researchers can submit "jobs" that automatically trigger the reward mechanism.
* **Automated Reward Distribution:** Using **Canister Timers**, the platform automatically distributes `DTH` tokens to contributors after a "job" is completed, showcasing the autonomous execution capabilities of ICP smart contracts.

## **3. Application Architecture**

DeAITH is built on a multi-canister architecture to ensure modularity and scalability.

* **`DeAITH_frontend`**: An *asset* canister that serves our user interface (UI) built with React.
* **`UserData`**: A Motoko canister responsible for storing the encrypted data from patients and managing their profiles.
* **`RewardToken`**: A Motoko canister that implements our fungible token `DTH`, complete with `mint`, `transfer`, and `balanceOf` functions.
* **`TrainingManager`**: The "brain" of our simulation. This Motoko canister receives jobs from researchers, sets timers, and orchestrates reward distribution by calling the `UserData` and `RewardToken` canisters.

### Architecture Diagram

*[Place your architecture diagram image here. [cite_start]This is a bonus point! [cite: 460]]*
`![Architecture Diagram](link_to_your_architecture_diagram.png)`

### Privacy Model & `vetKeys` Vision

Our architecture is designed for privacy from day one. While the full cryptographic implementation of `vetKeys` is part of our roadmap, the entire workflow and function hooks are already in place.

1.  **Initial Encryption:** The patient encrypts data in their browser.
2.  **Blind Storage:** The `UserData` canister stores this encrypted `Blob` without the ability to read it.
3.  **Access Request (`vetKeys` Vision):** A researcher requests access. The patient provides on-chain consent.
4.  [cite_start]**Key Derivation:** The `UserData` canister would then call the `vetKD` system API [cite: 588] to derive a temporary decryption key that can only be opened by the authorized researcher. Our platform never holds the key.

## **4. ICP Features Used**

* [cite_start]**Internet Identity:** For secure, decentralized, and user-friendly authentication[cite: 197].
* [cite_start]**Motoko:** The native language for the Internet Computer, enabling us to write safe and efficient smart contracts[cite: 473].
* [cite_start]**Stable Memory:** We use `stable var`s in all canisters to ensure data (token balances, encrypted data) persists across canister upgrades[cite: 485].
* [cite_start]**Canister Timers:** This feature is the core of our AI training simulation[cite: 457]. The `TrainingManager` uses `Timer.setTimer` to delay execution and automatically trigger reward distribution, showcasing the autonomous execution capabilities of ICP smart contracts.
* **Multi-Canister Architecture & Inter-Canister Calls:** Our application demonstrates how multiple canisters can work together harmoniously to create a complex application.

## **5. Technology Stack**

* **Backend:** Motoko
* **Frontend:** React, JavaScript, TailwindCSS
* **Encryption:** CryptoJS (for client-side encryption)
* **Tooling:** DFX, Node.js

## **6. Local Development (Build & Deployment)**

To run this project in a local environment, follow these steps. [cite_start]This covers the requirement for local development setup instructions[cite: 62, 452].

1.  **Prerequisites:**
    * Install the [DFX SDK](https://internetcomputer.org/docs/current/developer-docs/setup/install).
    * Install [Node.js](https://nodejs.org/en).

2.  **Clone the Repository:**
    ```bash
    git clone [URL_OF_YOUR_GITHUB_REPOSITORY]
    cd DeAITH
    ```

3.  **Install Dependencies:**
    ```bash
    npm install
    ```

4.  **Start the Local Replica:**
    Open a new terminal window, navigate to the project folder, and run:
    ```bash
    dfx start --clean --background
    ```

5.  **Deploy the Canisters:**
    Return to the first terminal window and run:
    ```bash
    dfx deploy
    ```
    *Note: You may need to perform inter-canister configuration after the initial deployment (e.g., calling `setMinter`).*

6.  **Run the Application:**
    Once the deployment is complete, the terminal will provide a URL for your local frontend.

## **7. Mainnet Canister IDs**

* **Frontend URL:** `[YOUR_FRONTEND_CANISTER_ID].icp0.io`
* **`UserData` Canister ID:** `[YOUR_USERDATA_CANISTER_ID]`
* **`RewardToken` Canister ID:** `[YOUR_REWARDTOKEN_CANISTER_ID]`
* **`TrainingManager` Canister ID:** `[YOUR_TRAININGMANAGER_CANISTER_ID]`

## **8. Challenges Faced**

* **Simulating a Complex Economy:** Designing and implementing a fully functional and automated economic loop (contribution -> job -> reward) in a short timeframe was a primary challenge. Our use of Canister Timers was our effective solution to demonstrate this complex interaction.
* **Architecting for Future-Proof Features:** Designing an architecture ready for an advanced primitive like `vetKeys` while keeping the scope manageable for a hackathon required strategic planning. We solved this with the "façade" approach, where the UI and function hooks are already in place to show our forward-thinking design.

## **9. Future Plans (Roadmap)**

* [cite_start]**Q4 2025: Full `vetKeys` Implementation:** Replace the "façade" with a full cryptographic implementation of `vetKeys` for data access consent management[cite: 689].
* [cite_start]**Q1 2026: Real AI Training Module:** Integrate the canister with external compute services via `HTTPS Outcalls` [cite: 90, 180] to run simple AI models, or explore more advanced on-chain inference.
* [cite_start]**Q2 2026: DAO Governance:** Launch a DAO where `DTH` token holders can vote on what data types are most needed and how the platform should evolve, possibly using an SNS structure[cite: 140].

## **10. Our Team**
