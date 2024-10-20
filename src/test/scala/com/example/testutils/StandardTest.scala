package com.example.testutils

import org.scalatest.matchers.should.Matchers
import org.scalatest.wordspec.AnyWordSpec
import org.scalatest.BeforeAndAfterAll

/**
  * extend this test for synchornous unit tests
  *
  */
class StandardTest
    extends AnyWordSpec
    with Matchers
    with BeforeAndAfterAll {
}