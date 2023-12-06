<?php

namespace Drupal\ffw_ass_datalayer;

use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Core\Routing\CurrentRouteMatch;

/**
 * Class NodeMetadataManager.
 */
class NodeMetadataManager {

  /**
   * The CurrentRouteMatch service.
   *
   * @var \Drupal\Core\Routing\CurrentRouteMatch
   */
  protected $currentRouteMatch;

  /**
   * The entity type manager service.
   *
   * @var \Drupal\Core\Entity\EntityTypeManagerInterface
   */
  protected EntityTypeManagerInterface $entityTypeManager;

  /**
   * Constructs an NodeMetadataManager object.
   *
   * @param \Drupal\Core\Routing\CurrentRouteMatch $route_match
   *   The config factory service.
   * @param \Drupal\Core\Entity\EntityTypeManagerInterface $entity_type_manager
   *   The entity type manager service.
   */
  public function __construct(CurrentRouteMatch $route_match, EntityTypeManagerInterface $entity_type_manager) {
    $this->currentRouteMatch = $route_match;
    $this->entityTypeManager = $entity_type_manager;
  }

  /**
   * {@inheritdoc}
   */
  public function getNodeMetadata() {
    $metadata = [];
    $node = $this->currentRouteMatch->getParameter('node');
    if ($node) {
      $node_title = $node->label();
      $metadata['pageTitle'] = $node_title;
      if ($node->hasField('field_category')) {
        $category_id = $node->field_category->target_id;
        $category = $this->entityTypeManager->getStorage('taxonomy_term')->load($category_id);
        $category_title = $category->label();
        $metadata['category'] = $category_title;
      }
      if ($node->hasField('field_paragraphs')) {
        foreach ($node->field_paragraphs->getValue() as $value) {
          $component = $this->entityTypeManager->getStorage('paragraph')->load($value['target_id']);
          foreach ($component->getFields() as $name => $field) {
            $component_fields[$name] = $field->getString();
          }
          $metadata['components'][] = $component_fields;
        }
      }
    }

    return $metadata;
  }
}
