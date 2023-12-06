<?php

namespace Drupal\ffw_ass_extended_datalayer;

use Drupal\Core\DependencyInjection\ContainerBuilder;
use Drupal\Core\DependencyInjection\ServiceProviderBase;

/**
 * Modifies the language manager service.
 */
class FfwAssExtendedDatalayerServiceProvider extends ServiceProviderBase {

  /**
   * {@inheritdoc}
   */
  public function alter(ContainerBuilder $container) {
    if ($container->hasDefinition('ffw_ass_datalayer.metadata')) {
      $definition = $container->getDefinition('ffw_ass_datalayer.metadata');
      $definition->setClass('Drupal\ffw_ass_extended_datalayer\ExtendedDatalayer');
    }
  }

}