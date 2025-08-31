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

### 📸 Screenshots
<p align="center">
  <img src="https://ik.imagekit.io/ROVOID/Main%20Page%20Dark.png" alt="ETH Hunter Dark Mode" width="48%">
  <img src="https://ik.imagekit.io/ROVOID/Main%20Page%20Light.png" alt="ETH Hunter Light Mode" width="48%">
</p>
<p align="center">
  <img src="https://ik.imagekit.io/ROVOID/Settings.png" alt="Settings Page Screenshot" width="48%">
  <img src="https://ik.imagekit.io/ROVOID/History.png" alt="History Dialog Screenshot" width="48%">
</p>
<p align="center">
  <img src="https://ik.imagekit.io/ROVOID/ETH%20Hunter%20v1.0.1%20Android%201.jpg" alt="Android Home Page" width="25%">
  <img src="https://ik.imagekit.io/ROVOID/ETH%20Hunter%20v1.0.1%20Android%202.jpg" alt="Android Settings Page Light" width="25%">
  <img src="https://ik.imagekit.io/ROVOID/ETH%20Hunter%20v1.0.1%20Android%202.5.jpg" alt="Android Settings Page Dark" width="25%">
  <img src="https://ik.imagekit.io/ROVOID/ETH%20Hunter%20v1.0.1%20Android%203.jpg" alt="Android Scanner Stats" width="25%">
</p>

---

## 💻 Downloads

| ETH Hunter v1.0.1 | Download Link (Installer) | Download Link (Portable) |
| :--- | :---: | :---: |
| **Windows** (x64) | [**Download**](https://github.com/IMROVOID/ETH-Hunter/releases/download/v1.0.1/ETH-Hunter-v1.0.1-Windows-Setup.exe) | [**Download**](https://github.com/IMROVOID/ETH-Hunter/releases/download/v1.0.1/ETH-Hunter-v1.0.1-Windows-Portable.zip) |
| **macOS** (Intel & Apple Silicon) | [**Download**](https://github.com/IMROVOID/ETH-Hunter/releases/download/v1.0.1/ETH-Hunter-v1.0.1-macOS.dmg) | [**Download**](https://github.com/IMROVOID/ETH-Hunter/releases/download/v1.0.1/ETH-Hunter-v1.0.1-macOS-Portable.zip) |
| **Linux** (x64) | - | [**Download**](https://github.com/IMROVOID/ETH-Hunter/releases/download/v1.0.1/ETH-Hunter-v1.0.1-Linux-Portable.zip) |
| **Android** (.apk) | [**Download**](https://github.com/IMROVOID/ETH-Hunter/releases/download/v1.0.1/ETH-Hunter-v1.0.1-Android.apk) | - |

---

## 👨‍💻 For Developers

This section provides a guide for developers who want to understand the codebase, build from source, or contribute to the project.

### Codebase Overview

The project is structured to separate concerns, making it easier to navigate and maintain.

*   **`lib/main.dart`**: The entry point of the application. It handles platform-specific initializations (like setting up the desktop window size) and launches the main `MyApp` widget.
*   **`lib/providers/app_provider.dart`**: This is the core state management hub, using `ChangeNotifier` from the Provider package. It manages the application's entire state, including theme settings, API key storage, scanning status, log entries, and update checks.
*   **`lib/services/scanner_isolate.dart`**: This file contains the high-performance scanning logic. The entire process runs inside a separate `Isolate` (a different thread) to ensure the UI remains smooth and responsive. It communicates with the `AppProvider` using a `SendPort` to send back logs, winners, and API usage stats.
*   **`lib/screens/`**: This directory holds the UI for each of the main views in the application.
    *   `main_layout.dart`: The main scaffold that contains the sidebar for desktop and the bottom navigation bar for mobile. It manages the page view and the animated background.
    *   `scan_page.dart`: The UI for the primary scanning interface.
    *   `settings_page.dart`: The UI for managing the theme and Infura API keys.
    *   `about_page.dart`: The UI containing app info, social links, and donation details.
*   **`lib/core/theme/`**: Contains the theme definition (`app_theme.dart`), which uses a custom `ThemeExtension` (`CustomColors`) to define a rich, accessible color palette for both light and dark modes.

### Building from Source

To build and run this project locally, you'll need the Flutter SDK installed.

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/IMROVOID/ETH-Hunter.git
    ```
2.  **Navigate to the Project Directory:**
    ```bash
    cd ETH-Hunter
    ```
3.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the App:**
    Connect a device or start an emulator, then run the build command for your desired platform:
    ```bash
    # To run on Windows desktop
    flutter run -d windows

    # To run on macOS desktop
    flutter run -d macos

    # To run on Linux desktop
    flutter run -d linux

    # To run on an Android device
    flutter run -d android
    ```

### Using the GitHub Actions Workflow for Releases

This repository includes a pre-configured GitHub Actions workflow that automatically builds and releases the application for all supported platforms.

1.  **Fork the Repository:**
    Click the "Fork" button at the top right of this page to create your own copy of the repository.

2.  **Enable Actions on Your Fork:**
    Navigate to the "Actions" tab in your forked repository. You may need to enable workflows if they are disabled on forks by default.

3.  **Make Your Changes:**
    Clone your forked repository, create a new branch, and make any code modifications you need.

4.  **Push a New Version Tag:**
    The workflow is triggered when you push a tag that starts with `v` (e.g., `v1.0.2`, `v1.1.0`). To do this:
    ```bash
    # Commit your changes first
    git commit -am "My new feature"
    git push origin main

    # Create and push a new tag
    git tag v1.0.2
    git push origin v1.0.2
    ```

5.  **Monitor the Workflow:**
    Go to the "Actions" tab in your forked repository. You will see the "Build & Release" workflow running. It will build the app for Windows, macOS, Linux, and Android, then create a new **draft release** on your repository's "Releases" page with all the compiled application files attached as artifacts.

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
