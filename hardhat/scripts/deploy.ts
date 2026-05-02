import { ethers } from "ethers";
import hre from "hardhat";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  console.log("Starting deployment...\n");

  // Get provider and signer
  const provider = new ethers.JsonRpcProvider("http://localhost:8545");
  const signer = await provider.getSigner(0);

  // Read StudentManager ABI
  const studentManagerArtifact = JSON.parse(
    fs.readFileSync(
      path.join(
        __dirname,
        "../artifacts/contracts/StudentManager.sol/StudentManager.json",
      ),
      "utf8",
    ),
  );

  // Deploy StudentManager
  console.log("Deploying StudentManager...");
  const StudentManager = new ethers.ContractFactory(
    studentManagerArtifact.abi,
    studentManagerArtifact.bytecode,
    signer,
  );
  const studentManager = await StudentManager.deploy();
  await studentManager.waitForDeployment();
  const studentManagerAddress = await studentManager.getAddress();
  console.log("✓ StudentManager deployed at:", studentManagerAddress);

  // Read ScoreManager ABI
  const scoreManagerArtifact = JSON.parse(
    fs.readFileSync(
      path.join(
        __dirname,
        "../artifacts/contracts/ScoreManager.sol/ScoreManager.json",
      ),
      "utf8",
    ),
  );

  // Deploy ScoreManager with StudentManager address
  console.log("\nDeploying ScoreManager...");
  const ScoreManager = new ethers.ContractFactory(
    scoreManagerArtifact.abi,
    scoreManagerArtifact.bytecode,
    signer,
  );
  const scoreManager = await ScoreManager.deploy(studentManagerAddress);
  await scoreManager.waitForDeployment();
  const scoreManagerAddress = await scoreManager.getAddress();
  console.log("✓ ScoreManager deployed at:", scoreManagerAddress);

  // Summary
  console.log("\n=== Deployment Summary ===");
  console.log("StudentManager:", studentManagerAddress);
  console.log("ScoreManager:", scoreManagerAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
