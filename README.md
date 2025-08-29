<table>
  <tr>
    <td>
      <h1>💰 ETH Hunter</h1>
      <p>Welcome to ETH Hunter, a polished and open-source desktop application built with Flutter. This tool is designed as a conceptual exploration of the Ethereum blockchain, allowing users to scan for wallet addresses that contain a balance. It works by generating valid private keys, deriving their public addresses, and checking balances via the Infura API.</p>
      <p>The application is built for performance, using a separate Isolate for scanning to keep the UI perfectly smooth. It features multi-API key support, theme customization that syncs with your system's accent color, and automatic saving of any wallets found with a balance.</p>
    </td>
    <td align="right">
      <img src="https://ik.imagekit.io/ROVOID/ETH%20Hunter.png" alt="ETH Hunter App Screenshot" width="800">
    </td>
  </tr>
</table>

### 📸 Screenshots
<p align="center">
  <img src="https://ik.imagekit.io/ROVOID/Main%20Page%20Dark.png" alt="ETH Hunter Dark Mode" width="48%">
  <img src="https://ik.imagekit.io/ROVOID/Main%20Page%20Light.png" alt="ETH Hunter Light Mode" width="48%">
</p>
<p align="center">
  <img src="https://ik.imagekit.io/ROVOID/Settings.png" alt="Settings Page Screenshot" width="48%">
  <img src="https://ik.imagekit.io/ROVOID/History.png" alt="History Dialog Screenshot" width="48%">
</p>

---

## ✨ How to Use the App

The interface is designed for simplicity and power. Here’s a breakdown of all its features.

### 1. The Scan Page

This is the main control center for the application.

*   **Log Output:** The large central panel displays real-time logs of the scanning process. Each entry shows the scan number, current winner count, the wallet address, and its balance.
*   **Wallet Address:** Addresses with a balance are highlighted. You can click on any address to view it directly on Etherscan.
*   **Wallets to Scan:** Enter the total number of wallets you wish to scan in this session.
    *   Click the **∞ button** to set the value to the maximum number of requests available based on your entered API keys.
*   **Start / Stop Scanning:** This button starts or stops the scanning process. The UI remains fully responsive while scanning occurs in the background.

### 2. The Settings Page

This tab allows you to configure the application's core settings.

*   **Theme:**
    *   **System:** Automatically syncs with your operating system's Light or Dark mode and uses your system's accent color.
    *   **Light / Dark:** Manually lock the theme to your preferred mode.
*   **Infura API Keys:**
    *   Add one or more of your free Infura API keys. The application will automatically cycle through them if one key reaches its request limit or encounters an error.
    *   Click the **+ button** to add a new key field and the **x button** to remove one.
    *   Click the **ⓘ icon** for a helpful guide on how to get your own API key.

### 3. The About Page

This page contains information about the application, the developer, and how to donate.

*   **Update Checker:** The app automatically checks for new versions on startup. If an update is available, a "Download Update" button will appear, linking you directly to the latest release page on GitHub.
*   **Donation Addresses:** If you find the app useful, consider donating via the listed cryptocurrency addresses. Click the copy icon to easily copy an address.

### 4. The Sidebar

The sidebar provides navigation and at-a-glance statistics.

*   **Navigation:** Switch between the Scan, Settings, and About pages. The sidebar will collapse into an icon-only view on smaller window sizes.
*   **Stats Widget:**
    *   **Scanned:** A persistent counter of the total number of wallets scanned across all sessions.
    *   **Winners:** A persistent counter of the total number of wallets found with a balance.
    *   **Requests Left:** An estimate of the total remaining API requests for the current session across all your keys, visualized with a progress bar.

---

## 💻 Downloads

| Platform | Download Link |
| :--- | :---: |
| **Windows** (x64 Installer) | [**Download Setup**](https://github.com/IMROVOID/ETH-Hunter/releases/download/v1.0.0/ETH-Hunter-v1.0.0-Win-Setup.exe) |
| **Windows** (x64 Portable) | [**Download Portable**](https://github.com/IMROVOID/ETH-Hunter/releases/download/v1.0.0/ETH-Hunter-v1.0.0-Win-Portable.zip) |
| **macOS** (Intel & Apple Silicon) | *Coming Soon* |
| **Linux** (.deb / .AppImage) | *Coming Soon* |
| **Android** (.apk) | *Coming Soon* |

---

## 📜 License & Copyright

This project is completely open source and available to the public. You are free to use, modify, distribute, and fork this software for any purpose. No attribution is required, but it is appreciated.

---

## © About the Developer

This application was developed and is maintained by **Roham Andarzgou**.

I'm a passionate professional from Iran specializing in Graphic Design, Web Development, and cross-platform app development with Dart & Flutter. I thrive on turning innovative ideas into reality, whether it's a stunning visual, a responsive website, or a polished desktop app like this one. I also develop immersive games using Unreal Engine.

*   **Website:** [rovoid.ir](https://rovoid.ir)
*   **GitHub:** [IMROVOID](https://github.com/IMROVOID)
*   **LinkedIn:** [Roham Andarzgou](https://www.linkedin.com/in/roham-andarzgouu)

### 🙏 Support This Project

If you find this application useful, please consider a donation. As I am based in Iran, cryptocurrency is the only way I can receive support. Thank you!

| Cryptocurrency | Address |
| :--- | :--- |
| **Bitcoin** (BTC) | `bc1qd35yqx3xt28dy6fd87xzd62cj7ch35p68ep3p8` |
| **Ethereum** (ETH) | `0xA39Dfd80309e881cF1464dDb00cF0a17bF0322e3` |
| **USDT** (TRC20) | `THMe6FdXkA2Pw45yKaXBHRnkX3fjyKCzfy` |
| **Solana** (SOL) | `9QZHMTN4Pu6BCxiN2yABEcR3P4sXtBjkog9GXNxWbav1` |
| **TON** | `UQCp0OawnofpZTNZk-69wlqIx_wQpzKBgDpxY2JK5iynh3mC` |
