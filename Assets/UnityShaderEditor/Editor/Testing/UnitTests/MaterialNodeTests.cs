using System;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using UnityEngine;
using UnityEditor.Graphing;
using UnityEditor.ShaderGraph;

namespace UnityEditor.ShaderGraph.UnitTests
{
    [TestFixture]
    public class MaterialNodeTests
    {
        private ShaderGraph.MaterialGraph m_Graph;
        private TestNode m_NodeA;

        class TestNode : AbstractMaterialNode
        {
            public const int V1Out = 0;
            public const int V1In = 1;

            public TestNode()
            {
                AddSlot(new Vector1MaterialSlot(V1Out, "V1Out", "V1Out", SlotType.Output, 0));
                AddSlot(new Vector1MaterialSlot(V1In, "V1In", "V1In", SlotType.Input, 0));
            }
        }

        [OneTimeSetUp]
        public void RunBeforeAnyTests()
        {
            Debug.unityLogger.logHandler = new ConsoleLogHandler();
        }

        [SetUp]
        public void TestSetUp()
        {
            m_Graph = new ShaderGraph.MaterialGraph();
            m_NodeA = new TestNode();
            m_Graph.AddNode(m_NodeA);
        }

        [Test]
        public void GetVariableNameForSlotThrowsWhenInvalid()
        {
            Assert.Throws<ArgumentException>(() => m_NodeA.GetVariableNameForSlot(666));
        }

        [Test]
        public void AddingNonMaterialSlotToNodeThrows()
        {
            Assert.Throws<ArgumentException>(() => m_NodeA.AddSlot(new TestSlot(0, string.Empty, SlotType.Input)));
        }

        [Test]
        public void ReplacingMaterialSlotPreservesTheOldCurrentValue()
        {
            m_NodeA.AddSlot(new Vector1MaterialSlot(TestNode.V1In, "V1In", "V1In", SlotType.Input, 0));
            Assert.AreEqual(2, m_NodeA.GetSlots<MaterialSlot>().Count());
            Assert.AreEqual(1, m_NodeA.GetInputSlots<MaterialSlot>().Count());

            var slot = m_NodeA.GetInputSlots<Vector1MaterialSlot>().FirstOrDefault();
            Assert.AreEqual(Vector4.one, slot.defaultValue);
            Assert.AreEqual(Vector4.zero, slot.value);
        }

        [Test]
        public void CanConvertConcreteSlotValueTypeToOutputChunkProperly()
        {
            Assert.AreEqual(string.Empty, NodeUtils.GetSlotDimension(ConcreteSlotValueType.Vector1));
            Assert.AreEqual("2", NodeUtils.GetSlotDimension(ConcreteSlotValueType.Vector2));
            Assert.AreEqual("3", NodeUtils.GetSlotDimension(ConcreteSlotValueType.Vector3));
            Assert.AreEqual("4", NodeUtils.GetSlotDimension(ConcreteSlotValueType.Vector4));
            Assert.AreEqual("Texture2D", NodeUtils.GetSlotDimension(ConcreteSlotValueType.Texture2D));
            Assert.AreEqual("2x2", NodeUtils.GetSlotDimension(ConcreteSlotValueType.Matrix2));
            Assert.AreEqual("3x3", NodeUtils.GetSlotDimension(ConcreteSlotValueType.Matrix3));
            Assert.AreEqual("4x4", NodeUtils.GetSlotDimension(ConcreteSlotValueType.Matrix4));
            Assert.AreEqual("SamplerState", NodeUtils.GetSlotDimension(ConcreteSlotValueType.SamplerState));
        }

        [Test]
        public void CanGetDefaultInputsFromNodeAsPreviewProperties()
        {
            var properties = new List<PreviewProperty>();
            m_NodeA.CollectPreviewMaterialProperties(properties);
            var slot = m_NodeA.GetInputSlots<Vector1MaterialSlot>().FirstOrDefault();

            Assert.AreEqual(1, properties.Count);
            var pp = properties.FirstOrDefault();

            Assert.AreEqual(m_NodeA.GetVariableNameForSlot(slot.id), pp.name);
            Assert.AreEqual(PropertyType.Vector1, pp.propType);
            Assert.AreEqual(slot.value, pp.vector4Value);
        }

        [Test]
        public void CanGetDefaultSlotValueWhenNoEdgesConnected()
        {
            string expected = string.Format("{0}", m_NodeA.GetVariableNameForSlot(TestNode.V1In));

            var slot = m_NodeA.GetInputSlots<MaterialSlot>().FirstOrDefault();
            var result = m_NodeA.GetSlotValue(slot.id, GenerationMode.Preview);
            Assert.AreEqual(expected, result);
        }

        /*       [Test]
               public void NodeGenerateCorrectPreviewPropertyUsages()
               {
                   string expected = string.Format("{0} {1};{2}", AbstractMaterialNode.OutputPrecision.@fixed, m_NodeA.GetVariableNameForSlot(TestNode.V1In), Environment.NewLine);
                   var visitor = new ShaderGenerator();
                   m_NodeA.precision = AbstractMaterialNode.OutputPrecision.@fixed;
                   m_NodeA.GeneratePropertyUsages(visitor, GenerationMode.Preview);
                   Assert.AreEqual(expected, visitor.GetShaderString(0));

                   expected = string.Format("{0} {1};{2}", AbstractMaterialNode.OutputPrecision.@float, m_NodeA.GetVariableNameForSlot(TestNode.V1In), Environment.NewLine);
                   visitor = new ShaderGenerator();
                   m_NodeA.precision = AbstractMaterialNode.OutputPrecision.@float;
                   m_NodeA.GeneratePropertyUsages(visitor, GenerationMode.Preview);
                   Assert.AreEqual(expected, visitor.GetShaderString(0));

                   expected = string.Format("{0} {1};{2}", AbstractMaterialNode.OutputPrecision.half, m_NodeA.GetVariableNameForSlot(TestNode.V1In), Environment.NewLine);
                   visitor = new ShaderGenerator();
                   m_NodeA.precision = AbstractMaterialNode.OutputPrecision.half;
                   m_NodeA.GeneratePropertyUsages(visitor, GenerationMode.Preview);
                   Assert.AreEqual(expected, visitor.GetShaderString(0));
               }*/
    }
}
