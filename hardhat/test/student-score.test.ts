import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

async function expectRevert(promise: Promise<unknown>, reason: string) {
  try {
    await promise;
    expect.fail(`Expected revert with: ${reason}`);
  } catch (error: any) {
    expect(error.message ?? String(error)).to.include(reason);
  }
}

async function increaseTime(seconds: number) {
  await ethers.provider.send("evm_increaseTime", [seconds]);
  await ethers.provider.send("evm_mine", []);
}

describe("StudentManager / ScoreManager", function () {
  let admin: any;
  let teacher: any;
  let student: any;
  let secondStudent: any;
  let outsider: any;
  let studentManager: any;
  let scoreManager: any;

  beforeEach(async function () {
    [admin, teacher, student, secondStudent, outsider] =
      await ethers.getSigners();

    studentManager = await ethers.deployContract("StudentManager");
    const studentManagerAddress = await studentManager.getAddress();

    scoreManager = await ethers.deployContract("ScoreManager", [
      studentManagerAddress,
    ]);

    await studentManager.addTeacher(await teacher.getAddress());
    await scoreManager.addTeacher(await teacher.getAddress());

    await studentManager
      .connect(teacher)
      .addStudent("S001", await student.getAddress(), "Student One");
  });

  it("admin add teacher ok", async function () {
    await studentManager.addTeacher(await outsider.getAddress());

    expect(
      await studentManager.hasRole(
        await studentManager.TEACHER_ROLE(),
        await outsider.getAddress(),
      ),
    ).to.equal(true);
  });

  it("teacher add student ok", async function () {
    await studentManager
      .connect(teacher)
      .addStudent("S002", await secondStudent.getAddress(), "Student Two");

    expect(
      await studentManager.isStudentRegistered(
        await secondStudent.getAddress(),
      ),
    ).to.equal(true);
    expect(
      await studentManager.isStudentActive(await secondStudent.getAddress()),
    ).to.equal(true);
  });

  it("teacher set score ok", async function () {
    await scoreManager
      .connect(teacher)
      .setScore(await student.getAddress(), "Math", 90);

    const score = await scoreManager.getScore(
      await student.getAddress(),
      "Math",
    );
    expect(score.value).to.equal(90n);
  });

  it("student getMyScore ok", async function () {
    await scoreManager
      .connect(teacher)
      .setScore(await student.getAddress(), "Math", 90);

    const myScore = await scoreManager.connect(student).getMyScore("Math");
    expect(myScore.value).to.equal(90n);
  });

  it("sua score trong 10 phut ok", async function () {
    await scoreManager
      .connect(teacher)
      .setScore(await student.getAddress(), "Math", 80);
    await increaseTime(9 * 60);
    await scoreManager
      .connect(teacher)
      .setScore(await student.getAddress(), "Math", 95);

    const score = await scoreManager.getScore(
      await student.getAddress(),
      "Math",
    );
    expect(score.value).to.equal(95n);
  });

  it("sua score sau 11 phut fail", async function () {
    await scoreManager
      .connect(teacher)
      .setScore(await student.getAddress(), "Math", 80);
    await increaseTime(11 * 60);

    await expectRevert(
      scoreManager
        .connect(teacher)
        .setScore(await student.getAddress(), "Math", 95),
      "Edit window expired",
    );
  });

  it("student khong duoc setScore", async function () {
    await expectRevert(
      scoreManager
        .connect(student)
        .setScore(await student.getAddress(), "Math", 100),
      "Only teacher/admin",
    );
  });
});
