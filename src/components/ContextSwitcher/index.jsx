import React, { useState, useEffect, Fragment, memo } from 'react';
import clsx from 'clsx';
import { Listbox, Transition } from '@headlessui/react';
import { CheckIcon, SelectorIcon } from '@heroicons/react/solid';
import { useHistory } from 'react-router-dom';
import { useAllDocsData } from '@docusaurus/plugin-content-docs/client';
import { string } from 'prop-types';

import {
  FcAcceptDatabase,
} from 'react-icons/fc';
import { Icon } from '@iconify/react';
import './ContextSwitcher.css';


const CONTEXTS = [
  // id is base_path
  {
    id: 'Default',
    name: 'Home',
    icon: 'ic:baseline-home',
    type: 'iconify',
  },
  {
    id: 'Kubernetes',
    name: 'Kubernetes',
    icon: 'logos:kubernetes',
    type: 'iconify',
  },
  {
    id: 'Linux-Guide',
    name: 'Linux Guide',
    icon: 'flat-color-icons:linux',
    type: 'iconify',
  },
  {
    id: 'Service-Mesh',
    name: 'Proxy, Gateway & Mesh',
    icon: 'simple-icons:istio',
    type: 'iconify', 
  },
  {
    id: 'Database',
    name: 'Database',
    icon: FcAcceptDatabase,
    type: 'react-icons',
  },
  {
    id: 'Integration-and-Delivery',
    name: 'Integration & Delivery',
    icon: 'devicon:azuredevops',
    type: 'iconify',
  },
  {
    id: 'Observability',
    name: 'Observability',
    icon: 'devicon:opentelemetry',
    type: 'iconify',
  },
  {
    id: 'Infrastructure-as-Code',
    name: 'Infrastructure as Code',
    icon: 'logos:terraform-icon',
    type: 'iconify',
  },
  {
    id: 'Storage',
    name: 'Storage',
    icon: 'icon-park:cloud-storage',
    type: 'iconify',
  },
];

const getContext = (id) => CONTEXTS.find((context) => context.id === id);

export const getCurrentPageInfo = () => {
  return window.location.pathname.split('/').slice(1);
};

const pathExists = (path, data) => {
  return data.docs.some((doc) => doc.path === path);
};

const ContextSwitcher = ({ className }) => {
  const [context, setContext] = useState(CONTEXTS[0]);
  const data = useAllDocsData();
  const history = useHistory();

  useEffect(() => {
    const [doc] = getCurrentPageInfo();

    const currContext = getContext(doc);
    if (currContext && currContext.id !== context.id) {
      setContext(currContext);
    }
  }, []);

  const handleChange = (newValue) => {
    setContext(newValue);
    const [, ...docPath] = getCurrentPageInfo();
    const newDoc = newValue.id;
    history.push(`/${newDoc}`);
  };

  return (
    <Listbox
      value={context}
      onChange={handleChange}
      className={clsx('relative', className)}
    >
      <div className="relative mt-1">
        <Listbox.Button className="relative flex h-12 w-full cursor-pointer items-center rounded-lg border-none gradient-background py-2 pl-3 pr-10 text-left outline-none focus:outline-none focus-visible:border-indigo-500 focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-opacity-75 focus-visible:ring-offset-2 focus-visible:ring-offset-orange-300 sm:text-sm">
          {/* ICONS */}
          <div key={context.id} className="flex items-center">
            {context.type === 'iconify' ? (
              <Icon icon={context.icon} className="icon-size mr-2 h-8" aria-hidden="true" alt={context.name} />
            ) : (
              <context.icon className="icon-size mr-2 h-8" aria-hidden="true" alt={context.name} />
            )}
          </div>
          <span className="lv0_link block truncate text-text">
            {context.name}
          </span>
          <span className="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
            <SelectorIcon
              className="h-5 w-5 text-gray-400"
              aria-hidden="true"
            />
          </span>
        </Listbox.Button>
        <div className="relative w-full">
          <Transition
            as={Fragment}
            leave="transition ease-in duration-100"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <Listbox.Options className="absolute z-10 mt-1 max-h-60 w-full list-none overflow-auto rounded-md bg-background-100 p-0 py-2 text-base shadow-lg ring-border-expand focus:outline-none sm:text-sm">
              {CONTEXTS.map((context) => (
                <Listbox.Option
                  key={context.id}
                  className={({ active }) =>
                    clsx(
                      'relative cursor-pointer select-none py-2 px-4',
                      active && 'bg-background-200'
                    )
                  }
                  value={context}
                >
                  {({ selected }) => (
                    <div className="flex items-center justify-between">
                      <div className="flex items-center">
                        {/* ICONS */}
                        <div key={context.id} className="flex items-center">
                          {context.type === 'iconify' ? (
                            <Icon icon={context.icon} className="icon-size mr-2 h-8" aria-hidden="true" alt={context.name} />
                          ) : (
                            <context.icon className="icon-size mr-2 h-8" aria-hidden="true" alt={context.name} />
                          )}
                        </div>
                        <span
                          className={clsx(
                            'block truncate',
                            selected ? 'font-medium' : 'font-normal'
                          )}
                        >
                          {context.name}
                        </span>
                      </div>
                      {selected ? (
                        <span className="left-0 flex items-center pl-3 text-blue-600">
                          <CheckIcon className="h-5 w-5" aria-hidden="true" />
                        </span>
                      ) : null}
                    </div>
                  )}
                </Listbox.Option>
              ))}
            </Listbox.Options>
          </Transition>
        </div>
      </div>
    </Listbox>
  );
};

ContextSwitcher.propTypes = {
  className: string,
};

export default memo(ContextSwitcher);
