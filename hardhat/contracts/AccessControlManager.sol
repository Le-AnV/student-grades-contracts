// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract AccessControlManager is AccessControl {
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Only admin");
        _;
    }

    modifier onlyTeacherOrAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(TEACHER_ROLE, msg.sender),
            "Only teacher/admin"
        );
        _;
    }

    function addTeacher(address teacher) external onlyAdmin {
        _grantRole(TEACHER_ROLE, teacher);
    }

    function removeTeacher(address teacher) external onlyAdmin {
        _revokeRole(TEACHER_ROLE, teacher);
    }

    function addStudentRole(address student) external onlyTeacherOrAdmin {
        _grantRole(STUDENT_ROLE, student);
    }

    function removeStudentRole(address student) external onlyTeacherOrAdmin {
        _revokeRole(STUDENT_ROLE, student);
    }
}